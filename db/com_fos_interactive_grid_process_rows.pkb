create or replace package body com_fos_interactive_grid_process_rows
as

-- =============================================================================
--
--  FOS = FOEX Open Source (fos.world), by FOEX GmbH, Austria (www.foex.at)
--
--  This plug-in executes PL/SQL code for each selected or filtered
--  Interactive Grid row.
--
--  License: MIT
--
--  GitHub: https://github.com/foex-open-source/fos-interactive-grid-process-rows
--
-- =============================================================================

c_plugin_name            constant varchar2(100) := 'FOS - Interactive Grid - Process Rows';
c_pk_collection_name     constant varchar2(100) := 'FOS_IG_PK';
c_bug_workaround_name    constant varchar2(100) := 'FOS_APEX_192_BUG_30665079_WORKAROUND';

function render
    ( p_dynamic_action apex_plugin.t_dynamic_action
    , p_plugin         apex_plugin.t_plugin
    )
return apex_plugin.t_dynamic_action_render_result
as
    l_return apex_plugin.t_dynamic_action_render_result;

    l_mode                     p_dynamic_action.attribute_01%type := p_dynamic_action.attribute_01;
    l_items_to_submit          apex_t_varchar2                    := apex_string.split(p_dynamic_action.attribute_03, ',');
    l_refresh_selection        boolean                            := instr(p_dynamic_action.attribute_15, 'refresh-selection')    > 0;
    l_refresh_grid             boolean                            := instr(p_dynamic_action.attribute_15, 'refresh-grid')         > 0;
    l_replace_on_client        boolean                            := instr(p_dynamic_action.attribute_15, 'client-substitutions') > 0;
    l_escape_message           boolean                            := instr(p_dynamic_action.attribute_15, 'escape-message')       > 0;

    l_ajax_identifier          varchar2(1000)                     := apex_plugin.get_ajax_identifier;
    l_init_js_fn               varchar2(32767)                    := nvl(apex_plugin_util.replace_substitutions(p_dynamic_action.init_javascript_code), 'undefined');
begin

    -- debugging
    if apex_application.g_debug
    then
        apex_plugin_util.debug_dynamic_action
          ( p_plugin         => p_plugin
          , p_dynamic_action => p_dynamic_action
          );
    end if;

    apex_css.add_file
      ( p_name           => apex_plugin_util.replace_substitutions('fostr#MIN#.css')
      , p_directory      => p_plugin.file_prefix || 'css/'
      , p_skip_extension => true
      , p_key            => 'fostr'
      );

    apex_javascript.add_library
      ( p_name           => apex_plugin_util.replace_substitutions('fostr#MIN#.js')
      , p_directory      => p_plugin.file_prefix || 'js/'
      , p_skip_extension => true
      , p_key            => 'fostr'
      );


    -- create a JS function call passing all settings as a JSON object
    --
    -- example:
    -- FOS.interactiveGrid.processRows({
    --    "action": {
    --        "affectedRegionId": "emp"
    --    }
    -- }, {
    --    "ajaxId": "fYS3t2c4SabnxV",
    --    "mode": "selection", // or "filtered"
    --    "itemsToSubmit": ["P1_ITEM"],
    --    "refreshSelection": true,
    --    "refreshGrid": false,
    --    "performSubstitutions": false,
    --    "escapeMessage": true
    -- });

    apex_json.initialize_clob_output;
    apex_json.open_object;

    apex_json.write('ajaxId'              , l_ajax_identifier);
    apex_json.write('mode'                , l_mode);
    apex_json.write('itemsToSubmit'       , l_items_to_submit);
    apex_json.write('refreshSelection'    , l_refresh_selection);
    apex_json.write('refreshGrid'         , l_refresh_grid);
    apex_json.write('performSubstitutions', l_replace_on_client);
    apex_json.write('escapeMessage'       , l_escape_message);

    apex_json.close_object;

    l_return.javascript_function := 'function(){FOS.interactiveGrid.processRows(this, ' || apex_json.get_clob_output || ', '|| l_init_js_fn || ');}';

    apex_json.free_output;

    return l_return;
end render;

/*
 * This helper function takes a stringified such as {"recordKeys":[["7839"],["7698"],["7782"],["7566"],["7788"]]}
 * or, if there are more primary keys: {"recordKeys":[["7839","KING"],["7698","BLAKE"],["7782","CLARK"],["7566","JONES"]]}
 * It then populates an APEX collection as such:
 * c001 | c002
 * -----+-----
 * 7839 | KING
 * 7698 | BLAKE
 * 7782 | CLARK
 */
procedure populate_pk_collection
  ( p_primary_keys_json   clob
  , p_primary_key_count   number
  )
as
    l_values          apex_json.t_values;
    l_elements        apex_t_varchar2;
    l_record_count    number;

    l_current_pk_part varchar2(4000);
    l_seq_id          number;
begin

    apex_json.parse
      ( p_values => l_values
      , p_source => p_primary_keys_json
      );

    apex_collection.create_or_truncate_collection(c_pk_collection_name);

    l_record_count := apex_json.get_count
                        ( p_values => l_values
                        , p_path   => 'recordKeys'
                        );

    -- for each primary key object. can contain multiple primary key columns
    for i in 1 .. l_record_count
    loop

        l_elements := apex_json.get_t_varchar2
                        ( p_values => l_values
                        , p_path   => 'recordKeys[%d]'
                        , p0       => i
                        );

        -- for each primary key column
        for j in 1 .. p_primary_key_count
        loop

            l_current_pk_part := apex_json.get_varchar2
                                   ( p_values => l_values
                                   , p_path   => 'recordKeys[%d][%d]'
                                   , p0       => i
                                   , p1       => j
                                   );

            if j = 1
            then
                l_seq_id := apex_collection.add_member
                              ( p_collection_name => c_pk_collection_name
                              , p_c001            => l_current_pk_part
                              );
            else
                apex_collection.update_member_attribute
                  ( p_collection_name => c_pk_collection_name
                  , p_seq             => l_seq_id
                  , p_attr_number     => j
                  , p_attr_value      => l_current_pk_part
                  );
            end if;
        end loop;
    end loop;
end populate_pk_collection;

function ajax
  ( p_dynamic_action apex_plugin.t_dynamic_action
  , p_plugin         apex_plugin.t_plugin
  )
return apex_plugin.t_dynamic_action_ajax_result
as

    l_affected_region_id varchar2(4000)                    := p_dynamic_action.affected_region_id;

    l_is_selection_mode boolean                            := p_dynamic_action.attribute_01 = 'selection';

    l_items_to_return   apex_t_varchar2                    := apex_string.split(p_dynamic_action.attribute_04, ',');

    l_plsql_code        p_dynamic_action.attribute_02%type := p_dynamic_action.attribute_02;

    l_success_message   p_dynamic_action.attribute_05%type := p_dynamic_action.attribute_05;
    l_error_message     p_dynamic_action.attribute_06%type := p_dynamic_action.attribute_06;
    l_message           varchar2(32767);
    l_message_title     varchar2(32767);

    l_escape_message    boolean                            := instr(p_dynamic_action.attribute_15, 'escape-message')       > 0;
    l_replace_on_client boolean                            := instr(p_dynamic_action.attribute_15, 'client-substitutions') > 0;

    l_context           apex_exec.t_context;

    --needed for the selection filter
    l_selected_records  clob                               := '';
    l_filters           apex_exec.t_filters;
    l_primary_key_count number                             := 0;
    l_primary_key_cols  apex_t_varchar2                    := apex_t_varchar2();
    l_collection_cols   apex_t_varchar2                    := apex_t_varchar2();
    l_current_column    apex_exec.t_column;
    l_context_filter    varchar2(4000);

    l_error_occurred    boolean                            := false;

    l_return apex_plugin.t_dynamic_action_ajax_result;

    --
    -- We won't escape serverside if we do it client side to avoid double escaping
    --
    function escape_html
      ( p_html                   in varchar2
      , p_escape_already_enabled in boolean
      ) return varchar2
    is
    begin
        return case when p_escape_already_enabled then p_html else apex_escape.html(p_html) end;
    end escape_html;

begin

    --debugging
    if apex_application.g_debug
    then
        apex_plugin_util.debug_dynamic_action
          ( p_plugin         => p_plugin
          , p_dynamic_action => p_dynamic_action
          );
    end if;

    apex_application.g_x01 := c_bug_workaround_name;

    -- when in selection mode, we must first compute the context filter, based on the records selected
    if l_is_selection_mode
    then

        -- only opening the context to get the column and primary key information
        l_context := apex_region.open_query_context
                       ( p_page_id     => V('APP_PAGE_ID')
                       , p_region_id   => l_affected_region_id
                       , p_max_rows    => 0
                       );

        --rebuilding the primary key json
        for idx in 1 .. apex_application.g_f01.count
        loop
            l_selected_records := l_selected_records || apex_application.g_f01(idx);
        end loop;

        -- looping through all columns to find the primary keys
        for idx in 1 .. apex_exec.get_column_count(l_context)
        loop

            l_current_column := apex_exec.get_column
                                  ( p_context     => l_context
                                  , p_column_idx  => idx
                                  );

            -- in case the column is a primary key, we add it to the array,
            -- as well as the c00x cokumn it is mapped to
            if l_current_column.is_primary_key
            then
                l_primary_key_count                          := l_primary_key_count + 1;
                l_primary_key_cols.extend(1);
                l_primary_key_cols(l_primary_key_cols.count) := l_current_column.name;

                l_collection_cols.extend(1);
                l_collection_cols(l_collection_cols.count)   := 'c' || lpad(l_collection_cols.count, 3, '0');
            end if;

        end loop;

        -- if there are no primary keys defines, raise an error
        if l_primary_key_cols.count = 0
        then
            raise_application_error(-20000, 'The Interactive Grid referenced by "' || c_plugin_name || '" must have a primary key defined.');
        end if;

        -- now construct the filter (where clause) to apply to the context later on
        l_context_filter := '(#PRIMARY_KEY_COLUMNS#) in (select #COLLECTION_COLUMNS# from apex_collections where collection_name = ''#COLLECTION_NAME#'')';
        l_context_filter := replace(l_context_filter, '#PRIMARY_KEY_COLUMNS#', apex_string.join(l_primary_key_cols, ','));
        l_context_filter := replace(l_context_filter, '#COLLECTION_COLUMNS#', apex_string.join(l_collection_cols, ','));
        l_context_filter := replace(l_context_filter, '#COLLECTION_NAME#', c_pk_collection_name);

        -- adding the filter to the context
        apex_exec.add_filter
          ( p_filters         => l_filters
          , p_sql_expression  => l_context_filter
          );

        -- populating the collection with the primary keys
        populate_pk_collection
          ( p_primary_keys_json   => l_selected_records
          , p_primary_key_count   => l_primary_key_cols.count
          );

        apex_exec.close(l_context);
    end if;

    -- apply workaround for apex bug
    apex_application.g_x01 := c_bug_workaround_name;

    -- open the context, with a possible filter if in selection mode
    l_context := apex_region.open_query_context
                   ( p_page_id             => V('APP_PAGE_ID')
                   , p_region_id           => l_affected_region_id
                   , p_additional_filters  => l_filters
                   );

    -- resetting g_x01 to its original value as open_query_context is done parsing the columns
    apex_application.g_x01 := null;

    -- for each row, execute the provided plsql code
    begin
        while apex_exec.next_row(l_context)
        loop
            apex_exec.execute_plsql(l_plsql_code);
        end loop;
    exception
        when others then
            l_message := nvl(apex_application.g_x01, l_error_message);

            if not l_replace_on_client
            then
                l_message := apex_plugin_util.replace_substitutions(l_message);
            end if;

            if apex_application.g_x02 is not null
            then
                if not l_replace_on_client
                then
                    l_message_title := apex_plugin_util.replace_substitutions(apex_application.g_x02);
                end if;
            end if;

            l_message := replace(l_message, '#SQLCODE#', escape_html(sqlcode, l_escape_message));
            l_message := replace(l_message, '#SQLERRM#', escape_html(sqlerrm, l_escape_message));
            l_message := replace(l_message, '#SQLERRM_TEXT#', escape_html(substr(sqlerrm, instr(sqlerrm, ':')+1), l_escape_message));

            rollback;
            l_error_occurred := true;
    end;

    apex_exec.close(l_context);

    -- remove the collection if in selection mode
    if l_is_selection_mode
    then
        apex_collection.delete_collection(c_pk_collection_name);
    end if;

    -- construct the json response
    apex_json.open_object;

    if not l_error_occurred
    then
        apex_json.write('status', 'success');
        l_message := nvl(apex_application.g_x01, l_success_message);

        if not l_replace_on_client
        then
            l_message := apex_plugin_util.replace_substitutions(l_message);
        end if;
        apex_json.write('message', l_message);

        --
        -- the developer can optionally provide a message title and override the message type
        --
        if apex_application.g_x02 is not null
        then
            if not l_replace_on_client
            then
                l_message_title := apex_plugin_util.replace_substitutions(apex_application.g_x02);
            end if;
            apex_json.write('messageTitle', l_message_title);
        end if;

        if apex_application.g_x03 is not null
        then
            apex_json.write('messageType', apex_application.g_x03);
        end if;

        if l_items_to_return.count > 0
        then
            apex_json.open_array('itemsToReturn');

            for idx in 1 .. l_items_to_return.count
            loop
                apex_json.open_object;
                apex_json.write('name', l_items_to_return(idx));
                apex_json.write('value', V(l_items_to_return(idx)));
                apex_json.close_object;
            end loop;

            apex_json.close_array;
        end if;
    else
        apex_json.write('status'      , 'error');
        apex_json.write('message'     , l_message);
        apex_json.write('messageTitle', l_message_title);
    end if;

    -- the developer can cancel following actions
    apex_json.write('cancelActions', upper(apex_application.g_x04) IN ('CANCEL','STOP','TRUE'));

    -- the developer can fire an event if they desire
    apex_json.write('eventName', apex_application.g_x05);

    apex_json.close_object;

    return l_return;
exception
    when others
    then
        -- always ensure the context is closed, also in case of an error
        apex_exec.close(l_context);
        raise;
end ajax;

end;
/


