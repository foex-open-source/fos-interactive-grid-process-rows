create or replace package body com_fos_interactive_grid_process_rows
as

c_plugin_name        constant varchar2(100) := 'FOS - Interactive Grid - Process Rows';
c_pk_collection_name constant varchar2(100) := 'FOS_IG_PK';

function render
    ( p_dynamic_action apex_plugin.t_dynamic_action
    , p_plugin         apex_plugin.t_plugin
    )
return apex_plugin.t_dynamic_action_render_result
as
    l_return apex_plugin.t_dynamic_action_render_result;

    l_affected_elem_type varchar2(100) := p_dynamic_action.affected_elements_type;
    l_affected_region_id varchar2(100) := p_dynamic_action.affected_region_id;

    l_region_static_id   varchar2(100);
    l_region_type        varchar2(100);

    l_is_selection_mode  boolean         := p_dynamic_action.attribute_01 = 'selection';
    l_items_to_submit    apex_t_varchar2 := apex_string.split(p_dynamic_action.attribute_03, ',');
    l_ajax_identifier    varchar2(100)   := apex_plugin.get_ajax_identifier;

begin

    -- debugging
    apex_plugin_util.debug_dynamic_action
        ( p_plugin         => p_plugin
        , p_dynamic_action => p_dynamic_action
        );

    if l_affected_region_id is null
    then
         raise_application_error(-20000, 'An Interactive Grid region must be provided as affected element for plug-in "' || c_plugin_name || '"');
    end if;

    -- getting the region static id and region type
    begin
        select nvl(static_id, 'R' || l_affected_region_id)
             , source_type
          into l_region_static_id
             , l_region_type
          from apex_application_page_regions
         where application_id = V('APP_ID')
           and page_id        = V('APP_PAGE_ID')
           and region_id      = l_affected_region_id;
    exception
        when no_data_found
        then
            raise_application_error(-20000, 'Plug-in "' || c_plugin_name || '" could not find an the affected element region.');
    end;

    -- make sure the region is of type "Interactive Grid"
    if l_region_type != 'Interactive Grid'
    then
        raise_application_error(-20000, 'The affected element of plug-in "' || c_plugin_name || '" must be an Interactive Grid region.');
    end if;

    apex_json.initialize_clob_output;
    apex_json.open_object;

    apex_json.write('regionId', l_region_static_id);
    apex_json.write('ajaxId', l_ajax_identifier);
    apex_json.write('submitSelectedRecords', l_is_selection_mode);
    apex_json.write('itemsToSubmit', l_items_to_submit);

    apex_json.close_object;

    l_return.javascript_function := 'function(){FOS.interactiveGrid.processRows(this, ' || apex_json.get_clob_output || ');}';

    apex_json.free_output;

    return l_return;
end;

procedure populate_pk_collection
    ( p_primary_keys_json   clob
    , p_primary_key_count   number
    )
as
    l_values        apex_json.t_values;
    l_elements      apex_t_varchar2;
    l_record_count  number;

    l_current_pk_part   varchar2(4000);
    l_seq_id            number;
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

    for i in 1 .. l_record_count
    loop

        l_elements := apex_json.get_t_varchar2
            ( p_values  => l_values
            , p_path    => 'recordKeys[%d]'
            , p0        => i
            );

        for j in 1 .. p_primary_key_count
        loop

            l_current_pk_part := apex_json.get_varchar2
                ( p_values  => l_values
                , p_path    => 'recordKeys[%d][%d]'
                , p0        => i
                , p1        => j
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
end;

function ajax
    ( p_dynamic_action apex_plugin.t_dynamic_action
    , p_plugin         apex_plugin.t_plugin
    )
return apex_plugin.t_dynamic_action_ajax_result
as

    c_bug_workaround_name   constant varchar2(4000) := 'FOS_APEX_192_BUG_30665079_WORKAROUND';

    l_affected_elem_type    constant varchar2(4000) := p_dynamic_action.affected_elements_type;
    l_affected_region_id    constant varchar2(4000) := p_dynamic_action.affected_region_id;

    l_is_selection_mode constant boolean := p_dynamic_action.attribute_01 = 'selection';

    c_items_to_return   constant apex_t_varchar2 := apex_string.split(p_dynamic_action.attribute_04, ',');

    c_plsql_code        constant varchar2(4000) := p_dynamic_action.attribute_02;

    l_region_static_id  varchar2(100);
    l_region_type       varchar2(100);

    l_context           apex_exec.t_context;

    --needed for the selection filter
    l_selected_records  clob := '';
    l_filters           apex_exec.t_filters;
    l_column_count      number;
    l_primary_key_count number := 0;
    l_primary_key_cols  apex_t_varchar2 := apex_t_varchar2();
    l_collection_cols   apex_t_varchar2 := apex_t_varchar2();
    l_current_column    apex_exec.t_column;
    l_context_filter    varchar2(4000);

    l_return apex_plugin.t_dynamic_action_ajax_result;

begin

    --debugging
    if apex_application.g_debug then
        apex_plugin_util.debug_dynamic_action
            ( p_plugin         => p_plugin
            , p_dynamic_action => p_dynamic_action
            );
    end if;

    apex_application.g_x01 := c_bug_workaround_name;

    if l_is_selection_mode then

        l_context := apex_region.open_query_context
            ( p_page_id     => V('APP_PAGE_ID')
            , p_region_id   => l_affected_region_id
            );

        --rebuilding the primary key json
        for idx in 1 .. apex_application.g_f01.count
        loop
            l_selected_records := l_selected_records || apex_application.g_f01(idx);
        end loop;

        l_column_count := apex_exec.get_column_count(l_context);

        for idx in 1 .. l_column_count
        loop

            l_current_column := apex_exec.get_column
                ( p_context     => l_context
                , p_column_idx  => idx
                );

            if l_current_column.is_primary_key
            then
                l_primary_key_count := l_primary_key_count + 1;
                l_primary_key_cols.extend(1);
                l_primary_key_cols(l_primary_key_cols.count) := l_current_column.name;

                l_collection_cols.extend(1);
                l_collection_cols(l_collection_cols.count) := 'c' || lpad(l_collection_cols.count, 3, '0');
            end if;

        end loop;

        if l_primary_key_cols.count = 0
        then
            raise_application_error(-20000, 'The Interactive Grid referenced by "' || c_plugin_name || '" must have a primary key.');
        end if;

        l_context_filter := '(#PRIMARY_KEY_COLUMNS#) in (select #COLLECTION_COLUMNS# from apex_collections where collection_name = ''#COLLECTION_NAME#'')';
        l_context_filter := replace(l_context_filter, '#PRIMARY_KEY_COLUMNS#', apex_string.join(l_primary_key_cols, ','));
        l_context_filter := replace(l_context_filter, '#COLLECTION_COLUMNS#', apex_string.join(l_collection_cols, ','));
        l_context_filter := replace(l_context_filter, '#COLLECTION_NAME#', c_pk_collection_name);

        apex_exec.add_filter
            ( p_filters         => l_filters
            , p_sql_expression  => l_context_filter
            );

        populate_pk_collection
            ( p_primary_keys_json   => l_selected_records
            , p_primary_key_count   => l_primary_key_cols.count
            );

        apex_exec.close(l_context);
    end if;

    apex_application.g_x01 := c_bug_workaround_name;

    l_context := apex_region.open_query_context
        ( p_page_id             => V('APP_PAGE_ID')
        , p_region_id           => l_affected_region_id
        , p_additional_filters  => l_filters
        );

    while apex_exec.next_row(l_context)
    loop
        apex_exec.execute_plsql(c_plsql_code);
    end loop;

    apex_exec.close(l_context);

    if l_is_selection_mode
    then
        apex_collection.delete_collection(c_pk_collection_name);
    end if;

    apex_json.open_object;
    apex_json.write('status', 'success');

    if c_items_to_return.count > 0
    then
        apex_json.open_array('itemsToReturn');

        for idx in 1 .. c_items_to_return.count
        loop
            apex_json.open_object;
            apex_json.write('name', c_items_to_return(idx));
            apex_json.write('value', V(c_items_to_return(idx)));
            apex_json.close_object;
        end loop;

        apex_json.close_array;
    end if;

    apex_json.close_object;

    return l_return;
exception
    when others
    then
        apex_exec.close(l_context);
        raise;
end;

end;
/


