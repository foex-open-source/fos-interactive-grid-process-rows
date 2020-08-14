

prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_190200 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2019.10.04'
,p_release=>'19.2.0.00.18'
,p_default_workspace_id=>1620873114056663
,p_default_application_id=>102
,p_default_id_offset=>0
,p_default_owner=>'FOS_MASTER_WS'
);
end;
/

prompt APPLICATION 102 - FOS Dev - Plugin Master
--
-- Application Export:
--   Application:     102
--   Name:            FOS Dev - Plugin Master
--   Exported By:     FOS_MASTER_WS
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 49755158803875939
--     PLUGIN: 13235263798301758
--     PLUGIN: 34615171094372499
--     PLUGIN: 37441962356114799
--     PLUGIN: 1846579882179407086
--     PLUGIN: 8354320589762683
--     PLUGIN: 50031193176975232
--     PLUGIN: 34175298479606152
--     PLUGIN: 35822631205839510
--     PLUGIN: 14934236679644451
--     PLUGIN: 2600618193722136
--     PLUGIN: 2657630155025963
--     PLUGIN: 284978227819945411
--   Manifest End
--   Version:         19.2.0.00.18
--   Instance ID:     250144500186934
--

begin
  -- replace components
  wwv_flow_api.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/dynamic_action/com_fos_interactive_grid_process_rows
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(50031193176975232)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'COM.FOS.INTERACTIVE_GRID_PROCESS_ROWS'
,p_display_name=>'FOS - Interactive Grid - Process Rows'
,p_category=>'EXECUTE'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_javascript_file_urls=>'#PLUGIN_FILES#js/script#MIN#.js'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- =============================================================================',
'--',
'--  FOS = FOEX Open Source (fos.world), by FOEX GmbH, Austria (www.foex.at)',
'--',
'--  This plug-in executes PL/SQL code for each selected or filtered ',
'--  Interactive Grid row.',
'--',
'--  License: MIT',
'--',
'--  GitHub: https://github.com/foex-open-source/fos-interactive-grid-process-rows',
'--',
'-- =============================================================================',
'',
'c_plugin_name            constant varchar2(100) := ''FOS - Interactive Grid - Process Rows'';',
'c_pk_collection_name     constant varchar2(100) := ''FOS_IG_PK'';',
'c_bug_workaround_name    constant varchar2(100) := ''FOS_APEX_192_BUG_30665079_WORKAROUND'';',
'',
'function render',
'    ( p_dynamic_action apex_plugin.t_dynamic_action',
'    , p_plugin         apex_plugin.t_plugin',
'    )',
'return apex_plugin.t_dynamic_action_render_result',
'as',
'    l_return apex_plugin.t_dynamic_action_render_result;',
'',
'    l_mode                     p_dynamic_action.attribute_01%type := p_dynamic_action.attribute_01;',
'    l_items_to_submit          apex_t_varchar2                    := apex_string.split(p_dynamic_action.attribute_03, '','');',
'    l_refresh_selection        boolean                            := instr(p_dynamic_action.attribute_15, ''refresh-selection'')    > 0;',
'    l_refresh_grid             boolean                            := instr(p_dynamic_action.attribute_15, ''refresh-grid'')         > 0;',
'    l_replace_on_client        boolean                            := instr(p_dynamic_action.attribute_15, ''client-substitutions'') > 0;',
'    l_escape_message           boolean                            := instr(p_dynamic_action.attribute_15, ''escape-message'')       > 0;',
'',
'    l_ajax_identifier          varchar2(1000)                     := apex_plugin.get_ajax_identifier;',
'    l_init_js_fn               varchar2(32767)                    := nvl(apex_plugin_util.replace_substitutions(p_dynamic_action.init_javascript_code), ''undefined'');',
'begin',
'',
'    -- debugging',
'    if apex_application.g_debug ',
'    then',
'        apex_plugin_util.debug_dynamic_action',
'          ( p_plugin         => p_plugin',
'          , p_dynamic_action => p_dynamic_action',
'          );',
'    end if;',
'',
'    apex_css.add_file ',
'      ( p_name           => apex_plugin_util.replace_substitutions(''fostr#MIN#.css'')',
'      , p_directory      => p_plugin.file_prefix || ''css/''',
'      , p_skip_extension => true',
'      , p_key            => ''fostr''',
'      );    ',
'',
'    apex_javascript.add_library ',
'      ( p_name           => apex_plugin_util.replace_substitutions(''fostr#MIN#.js'')',
'      , p_directory      => p_plugin.file_prefix || ''js/''',
'      , p_skip_extension => true',
'      , p_key            => ''fostr''',
'      );    ',
'',
'',
'    -- create a JS function call passing all settings as a JSON object',
'    --',
'    -- example:',
'    -- FOS.interactiveGrid.processRows({',
'    --    "action": {',
'    --        "affectedRegionId": "emp"',
'    --    }',
'    -- }, {',
'    --    "ajaxId": "fYS3t2c4SabnxV",',
'    --    "mode": "selection", // or "filtered"',
'    --    "itemsToSubmit": ["P1_ITEM"],',
'    --    "refreshSelection": true,',
'    --    "refreshGrid": false,',
'    --    "performSubstitutions": false,',
'    --    "escapeMessage": true',
'    -- });',
'',
'    apex_json.initialize_clob_output;',
'    apex_json.open_object;',
'',
'    apex_json.write(''ajaxId''              , l_ajax_identifier);',
'    apex_json.write(''mode''                , l_mode);',
'    apex_json.write(''itemsToSubmit''       , l_items_to_submit);',
'    apex_json.write(''refreshSelection''    , l_refresh_selection);',
'    apex_json.write(''refreshGrid''         , l_refresh_grid);',
'    apex_json.write(''performSubstitutions'', l_replace_on_client);',
'    apex_json.write(''escapeMessage''       , l_escape_message);',
'',
'    apex_json.close_object;',
'',
'    l_return.javascript_function := ''function(){FOS.interactiveGrid.processRows(this, '' || apex_json.get_clob_output || '', ''|| l_init_js_fn || '');}'';',
'',
'    apex_json.free_output;',
'',
'    return l_return;',
'end render;',
'',
'/* ',
' * This helper function takes a stringified such as {"recordKeys":[["7839"],["7698"],["7782"],["7566"],["7788"]]}',
' * or, if there are more primary keys: {"recordKeys":[["7839","KING"],["7698","BLAKE"],["7782","CLARK"],["7566","JONES"]]}',
' * It then populates an APEX collection as such:',
' * c001 | c002',
' * -----+-----',
' * 7839 | KING',
' * 7698 | BLAKE',
' * 7782 | CLARK',
' */',
'procedure populate_pk_collection',
'  ( p_primary_keys_json   clob',
'  , p_primary_key_count   number',
'  )',
'as',
'    l_values          apex_json.t_values;',
'    l_elements        apex_t_varchar2;',
'    l_record_count    number;',
'',
'    l_current_pk_part varchar2(4000);',
'    l_seq_id          number;',
'begin',
'',
'    apex_json.parse',
'      ( p_values => l_values',
'      , p_source => p_primary_keys_json',
'      );',
'',
'    apex_collection.create_or_truncate_collection(c_pk_collection_name);',
'',
'    l_record_count := apex_json.get_count',
'                        ( p_values => l_values',
'                        , p_path   => ''recordKeys''',
'                        );',
'',
'    -- for each primary key object. can contain multiple primary key columns',
'    for i in 1 .. l_record_count',
'    loop',
'',
'        l_elements := apex_json.get_t_varchar2',
'                        ( p_values => l_values',
'                        , p_path   => ''recordKeys[%d]''',
'                        , p0       => i',
'                        );',
'',
'        -- for each primary key column',
'        for j in 1 .. p_primary_key_count',
'        loop',
'',
'            l_current_pk_part := apex_json.get_varchar2',
'                                   ( p_values => l_values',
'                                   , p_path   => ''recordKeys[%d][%d]''',
'                                   , p0       => i',
'                                   , p1       => j',
'                                   );',
'',
'            if j = 1',
'            then',
'                l_seq_id := apex_collection.add_member',
'                              ( p_collection_name => c_pk_collection_name',
'                              , p_c001            => l_current_pk_part',
'                              );',
'            else',
'                apex_collection.update_member_attribute',
'                  ( p_collection_name => c_pk_collection_name',
'                  , p_seq             => l_seq_id',
'                  , p_attr_number     => j',
'                  , p_attr_value      => l_current_pk_part',
'                  );',
'            end if;',
'        end loop;',
'    end loop;',
'end populate_pk_collection;',
'',
'function ajax',
'  ( p_dynamic_action apex_plugin.t_dynamic_action',
'  , p_plugin         apex_plugin.t_plugin',
'  )',
'return apex_plugin.t_dynamic_action_ajax_result',
'as',
'',
'    l_affected_region_id varchar2(4000)                    := p_dynamic_action.affected_region_id;',
'',
'    l_is_selection_mode boolean                            := p_dynamic_action.attribute_01 = ''selection'';',
'    ',
'    l_items_to_return   apex_t_varchar2                    := apex_string.split(p_dynamic_action.attribute_04, '','');',
'',
'    l_plsql_code        p_dynamic_action.attribute_02%type := p_dynamic_action.attribute_02;',
'',
'    l_success_message   p_dynamic_action.attribute_05%type := p_dynamic_action.attribute_05;',
'    l_error_message     p_dynamic_action.attribute_06%type := p_dynamic_action.attribute_06;',
'    l_message           varchar2(32767);',
'    l_message_title     varchar2(32767);',
'    ',
'    l_escape_message    boolean                            := instr(p_dynamic_action.attribute_15, ''escape-message'')       > 0;',
'    l_replace_on_client boolean                            := instr(p_dynamic_action.attribute_15, ''client-substitutions'') > 0;',
'',
'    l_context           apex_exec.t_context;',
'',
'    --needed for the selection filter',
'    l_selected_records  clob                               := '''';',
'    l_filters           apex_exec.t_filters;',
'    l_primary_key_count number                             := 0;',
'    l_primary_key_cols  apex_t_varchar2                    := apex_t_varchar2();',
'    l_collection_cols   apex_t_varchar2                    := apex_t_varchar2();',
'    l_current_column    apex_exec.t_column;',
'    l_context_filter    varchar2(4000);',
'    ',
'    l_error_occurred    boolean                            := false;',
'',
'    l_return apex_plugin.t_dynamic_action_ajax_result;',
'',
'    --',
'    -- We won''t escape serverside if we do it client side to avoid double escaping',
'    --',
'    function escape_html',
'      ( p_html                   in varchar2',
'      , p_escape_already_enabled in boolean',
'      ) return varchar2',
'    is ',
'    begin',
'        return case when p_escape_already_enabled then p_html else apex_escape.html(p_html) end;',
'    end escape_html;',
'',
'begin',
'',
'    --debugging',
'    if apex_application.g_debug ',
'    then',
'        apex_plugin_util.debug_dynamic_action',
'          ( p_plugin         => p_plugin',
'          , p_dynamic_action => p_dynamic_action',
'          );',
'    end if;',
'',
'    apex_application.g_x01 := c_bug_workaround_name;',
'',
'    -- when in selection mode, we must first compute the context filter, based on the records selected',
'    if l_is_selection_mode ',
'    then',
'',
'        -- only opening the context to get the column and primary key information',
'        l_context := apex_region.open_query_context',
'                       ( p_page_id     => V(''APP_PAGE_ID'')',
'                       , p_region_id   => l_affected_region_id',
'                       , p_max_rows    => 0',
'                       );',
'',
'        --rebuilding the primary key json',
'        for idx in 1 .. apex_application.g_f01.count',
'        loop',
'            l_selected_records := l_selected_records || apex_application.g_f01(idx);',
'        end loop;',
'',
'        -- looping through all columns to find the primary keys',
'        for idx in 1 .. apex_exec.get_column_count(l_context)',
'        loop',
'',
'            l_current_column := apex_exec.get_column',
'                                  ( p_context     => l_context',
'                                  , p_column_idx  => idx',
'                                  );',
'',
'            -- in case the column is a primary key, we add it to the array,',
'            -- as well as the c00x cokumn it is mapped to',
'            if l_current_column.is_primary_key',
'            then',
'                l_primary_key_count                          := l_primary_key_count + 1;',
'                l_primary_key_cols.extend(1);',
'                l_primary_key_cols(l_primary_key_cols.count) := l_current_column.name;',
'',
'                l_collection_cols.extend(1);',
'                l_collection_cols(l_collection_cols.count)   := ''c'' || lpad(l_collection_cols.count, 3, ''0'');',
'            end if;',
'',
'        end loop;',
'',
'        -- if there are no primary keys defines, raise an error',
'        if l_primary_key_cols.count = 0',
'        then',
'            raise_application_error(-20000, ''The Interactive Grid referenced by "'' || c_plugin_name || ''" must have a primary key defined.'');',
'        end if;',
'',
'        -- now construct the filter (where clause) to apply to the context later on',
'        l_context_filter := ''(#PRIMARY_KEY_COLUMNS#) in (select #COLLECTION_COLUMNS# from apex_collections where collection_name = ''''#COLLECTION_NAME#'''')'';',
'        l_context_filter := replace(l_context_filter, ''#PRIMARY_KEY_COLUMNS#'', apex_string.join(l_primary_key_cols, '',''));',
'        l_context_filter := replace(l_context_filter, ''#COLLECTION_COLUMNS#'', apex_string.join(l_collection_cols, '',''));',
'        l_context_filter := replace(l_context_filter, ''#COLLECTION_NAME#'', c_pk_collection_name);',
'',
'        -- adding the filter to the context',
'        apex_exec.add_filter',
'          ( p_filters         => l_filters',
'          , p_sql_expression  => l_context_filter',
'          );',
'',
'        -- populating the collection with the primary keys',
'        populate_pk_collection',
'          ( p_primary_keys_json   => l_selected_records',
'          , p_primary_key_count   => l_primary_key_cols.count',
'          );',
'',
'        apex_exec.close(l_context);',
'    end if;',
'',
'    -- apply workaround for apex bug',
'    apex_application.g_x01 := c_bug_workaround_name;',
'',
'    -- open the context, with a possible filter if in selection mode',
'    l_context := apex_region.open_query_context',
'                   ( p_page_id             => V(''APP_PAGE_ID'')',
'                   , p_region_id           => l_affected_region_id',
'                   , p_additional_filters  => l_filters',
'                   );',
'',
'    -- resetting g_x01 to its original value as open_query_context is done parsing the columns',
'    apex_application.g_x01 := null;',
'    ',
'    -- for each row, execute the provided plsql code',
'    begin',
'        while apex_exec.next_row(l_context)',
'        loop',
'            apex_exec.execute_plsql(l_plsql_code);',
'        end loop;',
'    exception',
'        when others then',
'            l_message := nvl(apex_application.g_x01, l_error_message);',
'            ',
'            if not l_replace_on_client ',
'            then',
'                l_message := apex_plugin_util.replace_substitutions(l_message);',
'            end if;',
'            ',
'            if apex_application.g_x02 is not null ',
'            then',
'                if not l_replace_on_client ',
'                then',
'                    l_message_title := apex_plugin_util.replace_substitutions(apex_application.g_x02);',
'                end if;',
'            end if;',
'',
'            l_message := replace(l_message, ''#SQLCODE#'', escape_html(sqlcode, l_escape_message));',
'            l_message := replace(l_message, ''#SQLERRM#'', escape_html(sqlerrm, l_escape_message));',
'            l_message := replace(l_message, ''#SQLERRM_TEXT#'', escape_html(substr(sqlerrm, instr(sqlerrm, '':'')+1), l_escape_message));',
'            ',
'            rollback;',
'            l_error_occurred := true;',
'    end;',
'',
'    apex_exec.close(l_context);',
'',
'    -- remove the collection if in selection mode',
'    if l_is_selection_mode',
'    then',
'        apex_collection.delete_collection(c_pk_collection_name);',
'    end if;',
'',
'    -- construct the json response',
'    apex_json.open_object;',
'    ',
'    if not l_error_occurred ',
'    then',
'        apex_json.write(''status'', ''success'');',
'        l_message := nvl(apex_application.g_x01, l_success_message);',
'        ',
'        if not l_replace_on_client ',
'        then',
'            l_message := apex_plugin_util.replace_substitutions(l_message);',
'        end if;',
'        apex_json.write(''message'', l_message);',
'',
'        -- ',
'        -- the developer can optionally provide a message title and override the message type',
'        --',
'        if apex_application.g_x02 is not null ',
'        then',
'            if not l_replace_on_client ',
'            then',
'                l_message_title := apex_plugin_util.replace_substitutions(apex_application.g_x02);',
'            end if;',
'            apex_json.write(''messageTitle'', l_message_title);',
'        end if;',
'        ',
'        if apex_application.g_x03 is not null ',
'        then',
'            apex_json.write(''messageType'', apex_application.g_x03);',
'        end if;',
'',
'        if l_items_to_return.count > 0',
'        then',
'            apex_json.open_array(''itemsToReturn'');',
'',
'            for idx in 1 .. l_items_to_return.count',
'            loop',
'                apex_json.open_object;',
'                apex_json.write(''name'', l_items_to_return(idx));',
'                apex_json.write(''value'', V(l_items_to_return(idx)));',
'                apex_json.close_object;',
'            end loop;',
'',
'            apex_json.close_array;',
'        end if;',
'    else',
'        apex_json.write(''status''      , ''error'');',
'        apex_json.write(''message''     , l_message);',
'        apex_json.write(''messageTitle'', l_message_title);',
'    end if;',
'    ',
'    -- the developer can cancel following actions',
'    apex_json.write(''cancelActions'', upper(apex_application.g_x04) IN (''CANCEL'',''STOP'',''TRUE''));',
'',
'    -- the developer can fire an event if they desire',
'    apex_json.write(''eventName'', apex_application.g_x05);',
'            ',
'    apex_json.close_object;',
'',
'    return l_return;',
'exception',
'    when others',
'    then',
'        -- always ensure the context is closed, also in case of an error',
'        apex_exec.close(l_context);',
'        raise;',
'end ajax;'))
,p_api_version=>2
,p_render_function=>'render'
,p_ajax_function=>'ajax'
,p_standard_attributes=>'REGION:REQUIRED:STOP_EXECUTION_ON_ERROR:WAIT_FOR_RESULT:INIT_JAVASCRIPT_CODE'
,p_substitute_attributes=>false
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>',
'    The <strong>FOS - Interactive Grid - Process Rows</strong> plug-in is used for bulk-processing rows of an interactive grid. It is a dynamic action that runs PL/SQL code on either only the selected rows or all filtered rows.',
'</p>',
'<p>',
'    You can pass page-items in and out of the PL/SQL code, display success and error messages, programmatically control success and error message content and behaviour, declaratively refresh the selected rows or the whole grid after completion, and i'
||'t also takes care of message substitutions and escaping.',
'</p>',
''))
,p_version_identifier=>'20.1.0'
,p_about_url=>'https://fos.world'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'// Settings for the FOS browser extension',
'@fos-auto-return-to-page',
'@fos-auto-open-files:js/script.js'))
,p_files_version=>238
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(50040767751628238)
,p_plugin_id=>wwv_flow_api.id(50031193176975232)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Action'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_default_value=>'selection'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'<p>The type of action to perform.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(50041402066630378)
,p_plugin_attribute_id=>wwv_flow_api.id(50040767751628238)
,p_display_sequence=>10
,p_display_value=>'Process Selected Rows'
,p_return_value=>'selection'
,p_help_text=>'<p>Process all rows which have been selected by the user</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(50041871274631858)
,p_plugin_attribute_id=>wwv_flow_api.id(50040767751628238)
,p_display_sequence=>20
,p_display_value=>'Process Filtered Rows'
,p_return_value=>'filtered'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Process all filtered rows.</p>',
'<p>Note that this refers to all filtered rows, meaning also the ones which have perhaps not been loaded into the page yet, due to pagination.</p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(50039704358510479)
,p_plugin_id=>wwv_flow_api.id(50031193176975232)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'PL/SQL Code'
,p_attribute_type=>'PLSQL'
,p_is_required=>true
,p_is_translatable=>false
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<pre>update emp',
'   set sal = sal + 100',
' where id = :ID;',
'<pre>'))
,p_help_text=>'<p>The PL/SQL code block to execute for each row.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(56630784952050881)
,p_plugin_id=>wwv_flow_api.id(50031193176975232)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Items to Submit'
,p_attribute_type=>'PAGE ITEMS'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'<p>Enter the page items to be set into session state when the process is initiated.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(56631941313053096)
,p_plugin_id=>wwv_flow_api.id(50031193176975232)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Items to Return'
,p_attribute_type=>'PAGE ITEMS'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'<p>Enter the page items to be returned from the server when the process is complete.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(39100200574612062)
,p_plugin_id=>wwv_flow_api.id(50031193176975232)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'Success Message'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Provide a success message which will be displayed as a success notification if the execution is completed successfully.</p>',
'<p>This message can be dynamically overridden in the PL/SQL Code block by assigning the new value to the apex_application.g_x01 global variable.</p>',
'<p>If no success message is provided, the success notification will not be shown.</p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(39101729939630014)
,p_plugin_id=>wwv_flow_api.id(50031193176975232)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_prompt=>'Error Message'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_default_value=>'#SQLERRM#'
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Provide an error message which will be displayed as an error notification if the execution raises an unhandled exception.</p>',
'<p>This message can be dynamically overridden in the PL/SQL Code block by assigning a new error message to the apex_application.g_x02 global variable.</p>',
'<p>If no error message is provided, the error notification will not be shown.</p>',
'<p>You can also use the #SQLCODE#, #SQLERRM# and #SQLERRM_TEXT# substitution strings for more detailed error information.</p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(33527798782162318)
,p_plugin_id=>wwv_flow_api.id(50031193176975232)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>15
,p_display_sequence=>150
,p_prompt=>'Extra Options'
,p_attribute_type=>'CHECKBOXES'
,p_is_required=>false
,p_default_value=>'escape-message'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'<p>Extra plug-in options.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(33528400652166937)
,p_plugin_attribute_id=>wwv_flow_api.id(33527798782162318)
,p_display_sequence=>10
,p_display_value=>'Refresh Selection After Processing'
,p_return_value=>'refresh-selection'
,p_help_text=>'<p>Refresh selected rows after processing.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(33528859808170460)
,p_plugin_attribute_id=>wwv_flow_api.id(33527798782162318)
,p_display_sequence=>20
,p_display_value=>'Refresh Grid After Processing'
,p_return_value=>'refresh-grid'
,p_help_text=>'<p>Refresh entire grid after processing.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(39116269621967173)
,p_plugin_attribute_id=>wwv_flow_api.id(33527798782162318)
,p_display_sequence=>30
,p_display_value=>'Replace Message Substitutions Client-side'
,p_return_value=>'client-substitutions'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>By default, item substitutions in success and error messages will be performed server-side, with session-state values, right after the processing has finished in the AJAX call.</p>',
'<p>This option enables you to override this, and perform the substitutions on the client, after the AJAX response has arrived, but before the notification is shown.</p>',
'',
'<p>Server-side substitutions are usually the desired method, as they are sure to use the latest session-state values, but can also replace application items, which the client does not have access to. Client-side substitutions are desired when substit'
||'uting for an item whose value exists on the client, but has not yet propagated to session-state.</p>'))
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(39117803934013192)
,p_plugin_attribute_id=>wwv_flow_api.id(33527798782162318)
,p_display_sequence=>40
,p_display_value=>'Escape Special Characters in Messages'
,p_return_value=>'escape-message'
,p_help_text=>'<p>Enable this option to escape any HTML tags in the success or error message. This should remain turned on by default to avoid any possibility of a cross-site-scripting attack. If however you do need to display HTML in a notification, you can turn t'
||'his setting off, but escape individual page items via the <code>&P1_ITEM!HTML.</code> syntax.</p>'
);
wwv_flow_api.create_plugin_std_attribute(
 p_id=>wwv_flow_api.id(38167419957727496)
,p_plugin_id=>wwv_flow_api.id(50031193176975232)
,p_name=>'INIT_JAVASCRIPT_CODE'
,p_is_required=>false
,p_depending_on_has_to_exist=>true
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<pre>function(config){',
'    config.refreshGrid = true;',
'}',
'</pre>'))
,p_help_text=>'Javascript function which allows you to override any settings right before the dynamic action is invoked.'
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '76617220464F533D77696E646F772E464F537C7C7B7D3B464F532E696E746572616374697665477269643D464F532E696E746572616374697665477269647C7C7B7D2C464F532E696E746572616374697665477269642E70726F63657373526F77733D66';
wwv_flow_api.g_varchar2_table(2) := '756E6374696F6E28652C742C72297B76617220732C613D22464F53202D20496E7465726163746976652047726964202D2050726F6365737320526F7773223B617065782E64656275672E696E666F28612C74292C733D7B6469736D6973733A5B226F6E43';
wwv_flow_api.g_varchar2_table(3) := '6C69636B222C226F6E427574746F6E225D2C6469736D69737341667465723A6E756C6C2C6E65776573744F6E546F703A21302C70726576656E744475706C6963617465733A21302C65736361706548746D6C3A21312C706F736974696F6E3A22746F702D';
wwv_flow_api.g_varchar2_table(4) := '7269676874222C69636F6E436C6173733A6E756C6C2C636C656172416C6C3A21317D2C7220696E7374616E63656F662046756E6374696F6E262628666F7374723D666F7374727C7C7B7D2C722E63616C6C28652C742C7329293B76617220692C6E2C6F3D';
wwv_flow_api.g_varchar2_table(5) := '652E616374696F6E2E6166666563746564526567696F6E49642C6C3D742E616A617849642C633D617065782E726567696F6E286F293B69662821637C7C22496E7465726163746976654772696422213D632E74797065297468726F77206E657720457272';
wwv_flow_api.g_varchar2_table(6) := '6F72282754686520616666656374656420656C656D656E74206F6620706C75672D696E2022272B612B2722206D75737420626520616E20496E746572616374697665204772696420726567696F6E2E27293B6966282273656C656374696F6E223D3D742E';
wwv_flow_api.g_varchar2_table(7) := '6D6F6465297B76617220753D632E63616C6C282267657453656C65637465645265636F72647322293B696628742E7265667265736853656C656374696F6E2626286E3D75292C303D3D752E6C656E677468297B617065782E64656275672E696E666F2822';
wwv_flow_api.g_varchar2_table(8) := '4E6F2073656C6563746564207265636F7264732E20436F6E74696E75696E6720776974686F7574207365727665722063616C6C2E22293B72657475726E20766F696420617065782E64612E726573756D6528652E726573756D6543616C6C6261636B2C21';
wwv_flow_api.g_varchar2_table(9) := '31297D76617220703D632E63616C6C28226765745669657773222C226772696422292E6D6F64656C2C643D7B7265636F72644B6579733A752E6D6170282866756E6374696F6E2865297B72657475726E20702E5F6765745072696D6172794B6579286529';
wwv_flow_api.g_varchar2_table(10) := '7D29297D3B693D617065782E7365727665722E6368756E6B284A534F4E2E737472696E67696679286429297D617065782E7365727665722E706C7567696E286C2C7B6630313A692C706167654974656D733A742E6974656D73546F5375626D69747D292E';
wwv_flow_api.g_varchar2_table(11) := '646F6E65282866756E6374696F6E2872297B76617220613D21312C693D722E6D6573736167652C6F3D722E6D6573736167655469746C652C6C3D722E6D6573736167655479706526265B22696E666F222C227761726E696E67222C227375636365737322';
wwv_flow_api.g_varchar2_table(12) := '2C226572726F72222C2264616E676572225D2E696E636C7564657328722E6D65737361676554797065293F722E6D657373616765547970653A2273756363657373223B6966286C3D2264616E676572223D3D3D6C3F226572726F72223A6C2C613D212172';
wwv_flow_api.g_varchar2_table(13) := '2E63616E63656C416374696F6E732C6F2626742E706572666F726D537562737469747574696F6E732626286F3D617065782E7574696C2E6170706C7954656D706C617465286F2C7B64656661756C7445736361706546696C7465723A6E756C6C7D29292C';
wwv_flow_api.g_varchar2_table(14) := '692626742E706572666F726D537562737469747574696F6E73262628693D617065782E7574696C2E6170706C7954656D706C61746528692C7B64656661756C7445736361706546696C7465723A6E756C6C7D29292C6F2626742E6573636170654D657373';
wwv_flow_api.g_varchar2_table(15) := '6167652626286F3D617065782E7574696C2E65736361706548544D4C286F29292C692626742E6573636170654D657373616765262628693D617065782E7574696C2E65736361706548544D4C286929292C2273756363657373223D3D722E737461747573';
wwv_flow_api.g_varchar2_table(16) := '297B696628722E6974656D73546F52657475726E29666F722876617220753D303B753C722E6974656D73546F52657475726E2E6C656E6774683B752B2B29617065782E6974656D28722E6974656D73546F52657475726E5B755D2E6E616D65292E736574';
wwv_flow_api.g_varchar2_table(17) := '56616C756528722E6974656D73546F52657475726E5B755D2E76616C7565293B742E7265667265736853656C656374696F6E2626632E63616C6C28226765745669657773222C226772696422292E6D6F64656C2E66657463685265636F726473286E292C';
wwv_flow_api.g_varchar2_table(18) := '742E72656672657368477269642626632E7265667265736828292C69262628242E657874656E6428732C7B6D6573736167653A6F3F693A766F696420302C7469746C653A6F7C7C692C747970653A6C7D292C666F7374725B6C5D287329297D656C736520';
wwv_flow_api.g_varchar2_table(19) := '613D21302C69262628242E657874656E6428732C7B6D6573736167653A6F3F693A766F696420302C7469746C653A6F7C7C692C747970653A226572726F72227D292C666F7374722E6572726F72287329293B722E6576656E744E616D652626617065782E';
wwv_flow_api.g_varchar2_table(20) := '6576656E742E747269676765722822626F6479222C722E6576656E744E616D652C72292C617065782E64612E726573756D6528652E726573756D6543616C6C6261636B2C61297D29292E6661696C282866756E6374696F6E28742C722C73297B61706578';
wwv_flow_api.g_varchar2_table(21) := '2E64612E68616E646C65416A61784572726F727328742C722C732C652E726573756D6543616C6C6261636B297D29297D3B0A2F2F2320736F757263654D617070696E6755524C3D7363726970742E6A732E6D6170';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(31016607903857402)
,p_plugin_id=>wwv_flow_api.id(50031193176975232)
,p_file_name=>'js/script.min.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '7B2276657273696F6E223A332C22736F7572636573223A5B227363726970742E6A73225D2C226E616D6573223A5B22464F53222C2277696E646F77222C22696E74657261637469766547726964222C2270726F63657373526F7773222C226461436F6E74';
wwv_flow_api.g_varchar2_table(2) := '657874222C22636F6E666967222C22696E6974466E222C22666F7374724F7074696F6E73222C22706C7567696E4E616D65222C2261706578222C226465627567222C22696E666F222C226469736D697373222C226469736D6973734166746572222C226E';
wwv_flow_api.g_varchar2_table(3) := '65776573744F6E546F70222C2270726576656E744475706C696361746573222C2265736361706548746D6C222C22706F736974696F6E222C2269636F6E436C617373222C22636C656172416C6C222C2246756E6374696F6E222C22666F737472222C2263';
wwv_flow_api.g_varchar2_table(4) := '616C6C222C22663031222C226F726967696E616C53656C656374696F6E222C22726567696F6E4964222C22616374696F6E222C226166666563746564526567696F6E4964222C22616A61784964222C22726567696F6E222C2274797065222C224572726F';
wwv_flow_api.g_varchar2_table(5) := '72222C226D6F6465222C2273656C65637465645265636F726473222C227265667265736853656C656374696F6E222C226C656E677468222C226461222C22726573756D65222C22726573756D6543616C6C6261636B222C226D6F64656C222C2273656C65';
wwv_flow_api.g_varchar2_table(6) := '6374696F6E222C227265636F72644B657973222C226D6170222C227265636F7264222C225F6765745072696D6172794B6579222C22736572766572222C226368756E6B222C224A534F4E222C22737472696E67696679222C22706C7567696E222C227061';
wwv_flow_api.g_varchar2_table(7) := '67654974656D73222C226974656D73546F5375626D6974222C22646F6E65222C2264617461222C2263616E63656C416374696F6E73222C226D657373616765222C226D6573736167655469746C65222C226D65737361676554797065222C22696E636C75';
wwv_flow_api.g_varchar2_table(8) := '646573222C22706572666F726D537562737469747574696F6E73222C227574696C222C226170706C7954656D706C617465222C2264656661756C7445736361706546696C746572222C226573636170654D657373616765222C2265736361706548544D4C';
wwv_flow_api.g_varchar2_table(9) := '222C22737461747573222C226974656D73546F52657475726E222C2269222C226974656D222C226E616D65222C2273657456616C7565222C2276616C7565222C2266657463685265636F726473222C227265667265736847726964222C22726566726573';
wwv_flow_api.g_varchar2_table(10) := '68222C2224222C22657874656E64222C22756E646566696E6564222C227469746C65222C226572726F72222C226576656E744E616D65222C226576656E74222C2274726967676572222C226661696C222C226A71584852222C2274657874537461747573';
wwv_flow_api.g_varchar2_table(11) := '222C226572726F725468726F776E222C2268616E646C65416A61784572726F7273225D2C226D617070696E6773223A22414145412C49414149412C4941414D432C4F41414F442C4B41414F2C4741437842412C49414149452C674241416B42462C494141';
wwv_flow_api.g_varchar2_table(12) := '49452C694241416D422C474167423743462C49414149452C674241416742432C594141632C53414155432C45414157432C45414151432C47414533442C49414349432C45414441432C454141612C774341456A42432C4B41414B432C4D41414D432C4B41';
wwv_flow_api.g_varchar2_table(13) := '414B482C45414159482C4741453542452C454141652C434143584B2C514141532C434141432C554141572C5941437242432C614141632C4B414364432C614141612C45414362432C6D4241416D422C4541436E42432C594141592C4541435A432C534141';
wwv_flow_api.g_varchar2_table(14) := '552C59414356432C554141572C4B414358432C554141552C47414956622C6141416B42632C5741436C42432C4D414151412C4F4141532C4741436A42662C4541414F67422C4B41414B6C422C45414157432C45414151452C4941476E432C494155496742';
wwv_flow_api.g_varchar2_table(15) := '2C45414341432C45415841432C4541415772422C4541415573422C4F41414F432C694241433542432C4541415376422C4541414F75422C4F41456842432C4541415370422C4B41414B6F422C4F41414F4A2C4741477A422C4941414B492C47414179422C';
wwv_flow_api.g_varchar2_table(16) := '6D42414166412C4541414F432C4B41436C422C4D41414D2C49414149432C4D41414D2C6F434141734376422C454141612C7943414F76452C4741416D422C61414166482C4541414F32422C4B414171422C43414335422C49414149432C4541416B424A2C';
wwv_flow_api.g_varchar2_table(17) := '4541414F502C4B41414B2C734241516C432C47414C496A422C4541414F36422C6D42414350562C4541416F42532C4741494D2C4741413142412C4541416742452C4F4141612C434143374231422C4B41414B432C4D41414D432C4B41414B2C7744414968';
wwv_flow_api.g_varchar2_table(18) := '422C59414441462C4B41414B32422C47414147432C4F41414F6A432C454141556B432C674241444C2C47414D78422C49414149432C45414151562C4541414F502C4B41414B2C574141592C5141415169422C4D41437843432C454141592C4341435A432C';
wwv_flow_api.g_varchar2_table(19) := '57414159522C4541416742532C4B4141492C53414155432C47414374432C4F41414F4A2C4541414D4B2C65414165442C4F4149704370422C4541414D642C4B41414B6F432C4F41414F432C4D41414D432C4B41414B432C55414155522C49414739422F42';
wwv_flow_api.g_varchar2_table(20) := '2C4B41414B6F432C4F41414F492C4F41414F72422C454141512C43414370434C2C4941414B412C4541434C32422C5541415737432C4541414F38432C6742414766432C4D41414B2C53414155432C4741436C422C49414149432C47414167422C45414568';
wwv_flow_api.g_varchar2_table(21) := '42432C45414155462C4541414B452C51414366432C45414165482C4541414B472C6141437042432C454141654A2C4541414B492C614141652C434141432C4F4141512C554141572C554141572C514141532C55414155432C534141534C2C4541414B492C';
wwv_flow_api.g_varchar2_table(22) := '61414167424A2C4541414B492C594141632C5541304231492C47417A4241412C4541412B422C5741416842412C45414134422C51414155412C4541477244482C4941416B42442C4541414B432C6341476E42452C47414167426E442C4541414F73442C75';
wwv_flow_api.g_varchar2_table(23) := '4241437642482C454141652F432C4B41414B6D442C4B41414B432C634141634C2C454141632C4341436A444D2C6F42414171422C5141477A42502C474141576C442C4541414F73442C754241436C424A2C4541415539432C4B41414B6D442C4B41414B43';
wwv_flow_api.g_varchar2_table(24) := '2C634141634E2C454141532C43414376434F2C6F42414171422C51414B7A424E2C47414167426E442C4541414F30442C674241437642502C454141652F432C4B41414B6D442C4B41414B492C57414157522C4941457043442C474141576C442C4541414F';
wwv_flow_api.g_varchar2_table(25) := '30442C674241436C42522C4541415539432C4B41414B6D442C4B41414B492C57414157542C49414768422C57414166462C4541414B592C4F414171422C43414731422C474141495A2C4541414B612C6341434C2C4941414B2C49414149432C454141492C';
wwv_flow_api.g_varchar2_table(26) := '45414147412C45414149642C4541414B612C634141632F422C4F41415167432C494143334331442C4B41414B32442C4B41414B662C4541414B612C63414163432C47414147452C4D41414D432C534141536A422C4541414B612C63414163432C47414147';
wwv_flow_api.g_varchar2_table(27) := '492C4F414B7A456C452C4541414F36422C6B424143504C2C4541414F502C4B41414B2C574141592C5141415169422C4D41414D69432C6141416168442C4741496E446E422C4541414F6F452C6141435035432C4541414F36432C554149506E422C494143';
wwv_flow_api.g_varchar2_table(28) := '416F422C45414145432C4F41414F72452C454141632C4341436E4267442C514141532C4541416942412C4F41415573422C4541437043432C4D41415374422C4741416742442C4541437A427A422C4B41414D32422C4941455670432C4D41414D6F432C47';
wwv_flow_api.g_varchar2_table(29) := '4141616C442C53414976422B432C47414167422C4541455A432C494143416F422C45414145432C4F41414F72452C454141632C4341436E4267442C514141532C4541416942412C4F41415573422C4541437043432C4D41415374422C4741416742442C45';
wwv_flow_api.g_varchar2_table(30) := '41437A427A422C4B41414D2C55414556542C4D41414D30442C4D41414D78452C49414B684238432C4541414B32422C5741434C76452C4B41414B77452C4D41414D432C514141512C4F41415137422C4541414B32422C5541415733422C4741472F433543';
wwv_flow_api.g_varchar2_table(31) := '2C4B41414B32422C47414147432C4F41414F6A432C454141556B432C654141674267422C4D4145314336422C4D41414B2C53414155432C4541414F432C45414159432C4741436A4337452C4B41414B32422C474141476D442C694241416942482C454141';
wwv_flow_api.g_varchar2_table(32) := '4F432C45414159432C454141616C462C454141556B43222C2266696C65223A227363726970742E6A73227D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(31017023053857403)
,p_plugin_id=>wwv_flow_api.id(50031193176975232)
,p_file_name=>'js/script.js.map'
,p_mime_type=>'application/json'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '77696E646F772E666F7374723D66756E6374696F6E28297B76617220653D2273756363657373222C743D22696E666F222C733D227761726E696E67222C6E3D226572726F72222C6F3D7B737563636573733A2266612D636865636B2D636972636C65222C';
wwv_flow_api.g_varchar2_table(2) := '696E666F3A2266612D696E666F2D636972636C65222C7761726E696E673A2266612D6578636C616D6174696F6E2D747269616E676C65222C6572726F723A2266612D74696D65732D636972636C65227D2C693D7B7D2C723D7B7D3B66756E6374696F6E20';
wwv_flow_api.g_varchar2_table(3) := '6328652C742C73297B72657475726E22737472696E67223D3D747970656F6620743F28737C7C28733D742C743D766F69642030292C6C287B747970653A652C6D6573736167653A742C7469746C653A737D29293A226F626A656374223D3D747970656F66';
wwv_flow_api.g_varchar2_table(4) := '20743F28742E747970653D652C6C287429293A766F696420636F6E736F6C652E6572726F722827666F737472206E6F74696669636174696F6E20226D6573736167652220706172616D657465722074797065206E6F7420737570706F727465642C206D75';
wwv_flow_api.g_varchar2_table(5) := '7374206265206120737472696E67206F72206F626A65637427297D66756E6374696F6E206128297B2428222E666F7374722D636F6E7461696E657222292E6368696C6472656E28292E72656D6F766528297D66756E6374696F6E206C2865297B76617220';
wwv_flow_api.g_varchar2_table(6) := '742C732C6E3D242E657874656E64287B7D2C242E657874656E64287B7D2C7B6469736D6973733A5B226F6E436C69636B222C226F6E427574746F6E225D2C6469736D69737341667465723A6E756C6C2C6E65776573744F6E546F703A21302C7072657665';
wwv_flow_api.g_varchar2_table(7) := '6E744475706C6963617465733A21312C65736361706548746D6C3A21302C706F736974696F6E3A22746F702D7269676874222C69636F6E436C6173733A6E756C6C2C636C656172416C6C3A21317D2C666F7374722E6F7074696F6E73292C65292C633D28';
wwv_flow_api.g_varchar2_table(8) := '743D6E2E706F736974696F6E2C695B745D7C7C66756E6374696F6E2865297B76617220743D2428223C6469762F3E22292E616464436C6173732822666F7374722D222B65292E616464436C6173732822666F7374722D636F6E7461696E657222293B7265';
wwv_flow_api.g_varchar2_table(9) := '7475726E20242822626F647922292E617070656E642874292C695B655D3D742C747D287429292C6C3D6E2E6469736D6973732E696E636C7564657328226F6E436C69636B22292C703D6E2E6469736D6973732E696E636C7564657328226F6E427574746F';
wwv_flow_api.g_varchar2_table(10) := '6E22292C643D2428273C64697620636C6173733D22666F732D416C65727420666F732D416C6572742D2D686F72697A6F6E74616C20666F732D416C6572742D2D7061676520272B7B737563636573733A22666F732D416C6572742D2D7375636365737322';
wwv_flow_api.g_varchar2_table(11) := '2C6572726F723A22666F732D416C6572742D2D64616E676572222C7761726E696E673A22666F732D416C6572742D2D7761726E696E67222C696E666F3A22666F732D416C6572742D2D696E666F227D5B6E2E747970655D2B272220726F6C653D22616C65';
wwv_flow_api.g_varchar2_table(12) := '7274223E3C2F6469763E27292C663D2428273C64697620636C6173733D22666F732D416C6572742D77726170223E27292C753D2428273C64697620636C6173733D22666F732D416C6572742D69636F6E223E3C2F6469763E27292C763D2428273C737061';
wwv_flow_api.g_varchar2_table(13) := '6E20636C6173733D22742D49636F6E20666120272B286E2E69636F6E436C6173737C7C6F5B6E2E747970655D292B27223E3C2F7370616E3E27292C6D3D2428273C64697620636C6173733D22666F732D416C6572742D636F6E74656E74223E3C2F646976';
wwv_flow_api.g_varchar2_table(14) := '3E27292C413D2428273C683220636C6173733D22666F732D416C6572742D7469746C65223E3C2F68323E27292C673D2428273C64697620636C6173733D22666F732D416C6572742D626F6479223E3C2F6469763E27292C773D2428273C64697620636C61';
wwv_flow_api.g_varchar2_table(15) := '73733D22666F732D416C6572742D627574746F6E73223E3C2F6469763E27293B70262628733D2428273C627574746F6E20636C6173733D22742D427574746F6E20742D427574746F6E2D2D6E6F554920742D427574746F6E2D2D69636F6E20742D427574';
wwv_flow_api.g_varchar2_table(16) := '746F6E2D2D636C6F7365416C6572742220747970653D22627574746F6E22207469746C653D22436C6F7365204E6F74696669636174696F6E223E3C7370616E20636C6173733D22742D49636F6E2069636F6E2D636C6F7365223E3C2F7370616E3E3C2F62';
wwv_flow_api.g_varchar2_table(17) := '7574746F6E3E2729292C642E617070656E642866292C662E617070656E642875292C752E617070656E642876292C662E617070656E64286D292C6D2E617070656E642841292C6D2E617070656E642867292C662E617070656E642877292C702626772E61';
wwv_flow_api.g_varchar2_table(18) := '7070656E642873293B76617220683D6E2E7469746C653B682626286E2E65736361706548746D6C262628683D617065782E7574696C2E65736361706548544D4C286829292C412E617070656E64286829293B76617220793D6E2E6D6573736167653B6966';
wwv_flow_api.g_varchar2_table(19) := '28792626286E2E65736361706548746D6C262628793D617065782E7574696C2E65736361706548544D4C287929292C672E617070656E64287929292C21286E2E70726576656E744475706C6963617465732626722626722E24656C656D2626722E24656C';
wwv_flow_api.g_varchar2_table(20) := '656D2E697328223A76697369626C6522292626722E7469746C653D3D682626722E6D6573736167653D3D7929297B766172206B3B73776974636828723D7B24656C656D3A642C7469746C653A682C6D6573736167653A797D2C6E2E636C656172416C6C26';
wwv_flow_api.g_varchar2_table(21) := '266128292C6E2E6E65776573744F6E546F703F632E70726570656E642864293A632E617070656E642864292C6E2E74797065297B636173652273756363657373223A6361736522696E666F223A6B3D22706F6C697465223B627265616B3B64656661756C';
wwv_flow_api.g_varchar2_table(22) := '743A6B3D22617373657274697665227D642E617474722822617269612D6C697665222C6B293B76617220623D2428223C6469762F3E22293B6966286E2E6469736D69737341667465723E30297B622E616464436C6173732822666F7374722D70726F6772';
wwv_flow_api.g_varchar2_table(23) := '65737322292C642E617070656E642862293B76617220433D73657454696D656F7574282866756E6374696F6E28297B642E72656D6F766528297D292C6E2E6469736D6973734166746572293B622E637373287B77696474683A2231303025222C7472616E';
wwv_flow_api.g_varchar2_table(24) := '736974696F6E3A22776964746820222B286E2E6469736D69737341667465722D313030292F3165332B2273206C696E656172227D292C73657454696D656F7574282866756E6374696F6E28297B622E63737328227769647468222C223022297D292C3130';
wwv_flow_api.g_varchar2_table(25) := '30292C642E6F6E28226D6F7573656F76657220636C69636B222C2866756E6374696F6E28297B636C65617254696D656F75742843292C622E72656D6F766528297D29297D72657475726E206C2626642E6F6E2822636C69636B222C2866756E6374696F6E';
wwv_flow_api.g_varchar2_table(26) := '28297B76617220653D77696E646F772E67657453656C656374696F6E28293B6526262252616E6765223D3D652E747970652626652E616E63686F724E6F646526262428652E616E63686F724E6F64652C64292E6C656E6774683E307C7C642E72656D6F76';
wwv_flow_api.g_varchar2_table(27) := '6528297D29292C702626732E6F6E2822636C69636B222C2866756E6374696F6E28297B642E72656D6F766528297D29292C2266756E6374696F6E223D3D747970656F66206E2E6F6E636C69636B262628642E6F6E2822636C69636B222C6E2E6F6E636C69';
wwv_flow_api.g_varchar2_table(28) := '636B292C702626732E6F6E2822636C69636B222C6E2E6F6E636C69636B29292C647D7D72657475726E7B737563636573733A66756E6374696F6E28742C73297B6328652C742C73297D2C696E666F3A66756E6374696F6E28652C73297B6328742C652C73';
wwv_flow_api.g_varchar2_table(29) := '297D2C7761726E696E673A66756E6374696F6E28652C74297B6328732C652C74297D2C6572726F723A66756E6374696F6E28652C74297B63286E2C652C74297D2C636C656172416C6C3A612C76657273696F6E3A2232302E312E30227D7D28293B0A2F2F';
wwv_flow_api.g_varchar2_table(30) := '2320736F757263654D617070696E6755524C3D666F7374722E6A732E6D6170';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(44242936244498692)
,p_plugin_id=>wwv_flow_api.id(50031193176975232)
,p_file_name=>'js/fostr.min.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2E666F732D416C6572742D2D686F72697A6F6E74616C7B626F726465722D7261646975733A3270783B6261636B67726F756E642D636F6C6F723A236666663B636F6C6F723A233236323632363B6D617267696E2D626F74746F6D3A312E3672656D3B706F';
wwv_flow_api.g_varchar2_table(2) := '736974696F6E3A72656C61746976653B626F726465723A31707820736F6C6964207267626128302C302C302C2E31293B626F782D736861646F773A302032707820347078202D327078207267626128302C302C302C2E303735297D2E666F732D416C6572';
wwv_flow_api.g_varchar2_table(3) := '742D69636F6E202E742D49636F6E7B636F6C6F723A236666667D2E666F732D416C6572742D2D7761726E696E67202E666F732D416C6572742D69636F6E202E742D49636F6E7B636F6C6F723A236662636634617D2E666F732D416C6572742D2D7761726E';
wwv_flow_api.g_varchar2_table(4) := '696E672E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D69636F6E7B6261636B67726F756E642D636F6C6F723A72676261283235312C3230372C37342C2E3135297D2E666F732D416C6572742D2D7375636365737320';
wwv_flow_api.g_varchar2_table(5) := '2E666F732D416C6572742D69636F6E202E742D49636F6E7B636F6C6F723A233362616132637D2E666F732D416C6572742D2D737563636573732E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D69636F6E7B6261636B';
wwv_flow_api.g_varchar2_table(6) := '67726F756E642D636F6C6F723A726762612835392C3137302C34342C2E3135297D2E666F732D416C6572742D2D696E666F202E666F732D416C6572742D69636F6E202E742D49636F6E7B636F6C6F723A233030373664667D2E666F732D416C6572742D2D';
wwv_flow_api.g_varchar2_table(7) := '696E666F2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D69636F6E7B6261636B67726F756E642D636F6C6F723A7267626128302C3131382C3232332C2E3135297D2E666F732D416C6572742D2D64616E676572202E';
wwv_flow_api.g_varchar2_table(8) := '666F732D416C6572742D69636F6E202E742D49636F6E7B636F6C6F723A236634343333367D2E666F732D416C6572742D2D64616E6765722E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D69636F6E7B6261636B6772';
wwv_flow_api.g_varchar2_table(9) := '6F756E642D636F6C6F723A72676261283234342C36372C35342C2E3135297D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D737563636573737B6261636B67726F756E642D636F6C6F723A726762612835392C3137302C34342C2E';
wwv_flow_api.g_varchar2_table(10) := '39293B636F6C6F723A236666667D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D73756363657373202E666F732D416C6572742D69636F6E7B6261636B67726F756E642D636F6C6F723A7472616E73706172656E743B636F6C6F72';
wwv_flow_api.g_varchar2_table(11) := '3A236666667D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D64616E676572202E666F732D416C6572742D69636F6E202E742D49636F6E2C2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D696E666F202E66';
wwv_flow_api.g_varchar2_table(12) := '6F732D416C6572742D69636F6E202E742D49636F6E2C2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D73756363657373202E666F732D416C6572742D69636F6E202E742D49636F6E2C2E666F732D416C6572742D2D706167652E66';
wwv_flow_api.g_varchar2_table(13) := '6F732D416C6572742D2D7761726E696E67202E666F732D416C6572742D69636F6E202E742D49636F6E7B636F6C6F723A696E68657269747D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D73756363657373202E742D427574746F';
wwv_flow_api.g_varchar2_table(14) := '6E2D2D636C6F7365416C6572747B636F6C6F723A2366666621696D706F7274616E747D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E677B6261636B67726F756E642D636F6C6F723A236662636634613B636F6C6F';
wwv_flow_api.g_varchar2_table(15) := '723A233434333430327D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E67202E666F732D416C6572742D69636F6E7B6261636B67726F756E642D636F6C6F723A7472616E73706172656E743B636F6C6F723A233434';
wwv_flow_api.g_varchar2_table(16) := '333430327D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E67202E742D427574746F6E2D2D636C6F7365416C6572747B636F6C6F723A2366666621696D706F7274616E747D2E666F732D416C6572742D2D70616765';
wwv_flow_api.g_varchar2_table(17) := '2E666F732D416C6572742D2D696E666F7B6261636B67726F756E642D636F6C6F723A233030373664663B636F6C6F723A236666667D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D696E666F202E666F732D416C6572742D69636F';
wwv_flow_api.g_varchar2_table(18) := '6E7B6261636B67726F756E642D636F6C6F723A7472616E73706172656E743B636F6C6F723A236666667D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D696E666F202E742D427574746F6E2D2D636C6F7365416C6572747B636F6C';
wwv_flow_api.g_varchar2_table(19) := '6F723A2366666621696D706F7274616E747D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D64616E6765727B6261636B67726F756E642D636F6C6F723A236634343333363B636F6C6F723A236666667D2E666F732D416C6572742D';
wwv_flow_api.g_varchar2_table(20) := '2D706167652E666F732D416C6572742D2D64616E676572202E666F732D416C6572742D69636F6E7B6261636B67726F756E642D636F6C6F723A7472616E73706172656E743B636F6C6F723A236666667D2E666F732D416C6572742D2D706167652E666F73';
wwv_flow_api.g_varchar2_table(21) := '2D416C6572742D2D64616E676572202E742D427574746F6E2D2D636C6F7365416C6572747B636F6C6F723A2366666621696D706F7274616E747D2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D777261707B646973';
wwv_flow_api.g_varchar2_table(22) := '706C61793A666C65783B666C65782D646972656374696F6E3A726F777D2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D69636F6E7B70616464696E673A3020313670783B666C65782D736872696E6B3A303B646973';
wwv_flow_api.g_varchar2_table(23) := '706C61793A666C65783B616C69676E2D6974656D733A63656E7465727D2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D636F6E74656E747B70616464696E673A313670783B666C65783A3120303B646973706C6179';
wwv_flow_api.g_varchar2_table(24) := '3A666C65783B666C65782D646972656374696F6E3A636F6C756D6E3B6A7573746966792D636F6E74656E743A63656E7465727D2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D627574746F6E737B666C65782D7368';
wwv_flow_api.g_varchar2_table(25) := '72696E6B3A303B746578742D616C69676E3A72696768743B77686974652D73706163653A6E6F777261703B70616464696E672D72696768743A312E3672656D3B646973706C61793A666C65783B616C69676E2D6974656D733A63656E7465727D2E752D52';
wwv_flow_api.g_varchar2_table(26) := '544C202E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D627574746F6E737B70616464696E672D72696768743A303B70616464696E672D6C6566743A312E3672656D7D2E666F732D416C6572742D2D686F72697A6F6E';
wwv_flow_api.g_varchar2_table(27) := '74616C202E666F732D416C6572742D626F64793A656D7074792C2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D627574746F6E733A656D7074797B646973706C61793A6E6F6E657D2E666F732D416C6572742D2D68';
wwv_flow_api.g_varchar2_table(28) := '6F72697A6F6E74616C202E666F732D416C6572742D7469746C657B666F6E742D73697A653A3272656D3B6C696E652D6865696768743A322E3472656D3B6D617267696E2D626F74746F6D3A307D2E666F732D416C6572742D2D686F72697A6F6E74616C20';
wwv_flow_api.g_varchar2_table(29) := '2E666F732D416C6572742D69636F6E202E742D49636F6E7B666F6E742D73697A653A333270783B77696474683A333270783B746578742D616C69676E3A63656E7465723B6865696768743A333270783B6C696E652D6865696768743A317D2E666F732D41';
wwv_flow_api.g_varchar2_table(30) := '6C6572742D2D6E6F49636F6E2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D69636F6E7B646973706C61793A6E6F6E6521696D706F7274616E747D2E666F732D416C6572742D2D6E6F49636F6E202E666F732D416C';
wwv_flow_api.g_varchar2_table(31) := '6572742D69636F6E202E742D49636F6E7B646973706C61793A6E6F6E657D2E742D426F64792D616C6572747B6D617267696E3A307D2E742D426F64792D616C657274202E666F732D416C6572747B6D617267696E2D626F74746F6D3A307D2E666F732D41';
wwv_flow_api.g_varchar2_table(32) := '6C6572742D2D706167657B7472616E736974696F6E3A2E327320656173652D6F75743B6D61782D77696474683A36343070783B6D696E2D77696474683A33323070783B7A2D696E6465783A313030303B626F726465722D77696474683A303B626F782D73';
wwv_flow_api.g_varchar2_table(33) := '6861646F773A3020302030202E3172656D207267626128302C302C302C2E312920696E7365742C302033707820397078202D327078207267626128302C302C302C2E31297D2E666F732D416C6572742D2D70616765202E666F732D416C6572742D627574';
wwv_flow_api.g_varchar2_table(34) := '746F6E737B70616464696E672D72696768743A307D2E666F732D416C6572742D2D70616765202E666F732D416C6572742D69636F6E7B70616464696E672D6C6566743A312E3672656D3B70616464696E672D72696768743A3870787D2E752D52544C202E';
wwv_flow_api.g_varchar2_table(35) := '666F732D416C6572742D2D70616765202E666F732D416C6572742D69636F6E7B70616464696E672D6C6566743A3870783B70616464696E672D72696768743A312E3672656D7D2E666F732D416C6572742D2D70616765202E666F732D416C6572742D6963';
wwv_flow_api.g_varchar2_table(36) := '6F6E202E742D49636F6E7B666F6E742D73697A653A323470783B77696474683A323470783B6865696768743A323470783B6C696E652D6865696768743A317D2E666F732D416C6572742D2D70616765202E666F732D416C6572742D626F64797B70616464';
wwv_flow_api.g_varchar2_table(37) := '696E672D626F74746F6D3A3870787D2E666F732D416C6572742D2D70616765202E666F732D416C6572742D636F6E74656E747B70616464696E673A3870787D2E666F732D416C6572742D2D70616765202E742D427574746F6E2D2D636C6F7365416C6572';
wwv_flow_api.g_varchar2_table(38) := '747B706F736974696F6E3A6162736F6C7574653B72696768743A2D3870783B746F703A2D3870783B70616464696E673A3470783B6D696E2D77696474683A303B6261636B67726F756E642D636F6C6F723A2330303021696D706F7274616E743B636F6C6F';
wwv_flow_api.g_varchar2_table(39) := '723A2366666621696D706F7274616E743B626F782D736861646F773A3020302030203170782072676261283235352C3235352C3235352C2E32352921696D706F7274616E743B626F726465722D7261646975733A323470783B7472616E736974696F6E3A';
wwv_flow_api.g_varchar2_table(40) := '7472616E73666F726D202E3132357320656173653B7472616E736974696F6E3A7472616E73666F726D202E3132357320656173652C2D7765626B69742D7472616E73666F726D202E3132357320656173657D2E752D52544C202E666F732D416C6572742D';
wwv_flow_api.g_varchar2_table(41) := '2D70616765202E742D427574746F6E2D2D636C6F7365416C6572747B72696768743A6175746F3B6C6566743A2D3870787D2E666F732D416C6572742D2D70616765202E742D427574746F6E2D2D636C6F7365416C6572743A686F7665727B2D7765626B69';
wwv_flow_api.g_varchar2_table(42) := '742D7472616E73666F726D3A7363616C6528312E3135293B7472616E73666F726D3A7363616C6528312E3135297D2E666F732D416C6572742D2D70616765202E742D427574746F6E2D2D636C6F7365416C6572743A6163746976657B2D7765626B69742D';
wwv_flow_api.g_varchar2_table(43) := '7472616E73666F726D3A7363616C65282E3835293B7472616E73666F726D3A7363616C65282E3835297D2E666F732D416C6572742D2D706167652E666F732D416C6572747B626F726465722D7261646975733A2E3472656D7D2E666F732D416C6572742D';
wwv_flow_api.g_varchar2_table(44) := '2D70616765202E666F732D416C6572742D7469746C657B70616464696E673A38707820307D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E67202E612D4E6F74696669636174696F6E7B6D617267696E2D72696768';
wwv_flow_api.g_varchar2_table(45) := '743A3870787D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E67202E612D4E6F74696669636174696F6E2D7469746C657B666F6E742D73697A653A312E3472656D3B6C696E652D6865696768743A3272656D3B666F';
wwv_flow_api.g_varchar2_table(46) := '6E742D7765696768743A3730303B6D617267696E3A307D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E67202E612D4E6F74696669636174696F6E2D6C6973747B6D61782D6865696768743A31323870787D2E666F';
wwv_flow_api.g_varchar2_table(47) := '732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6C6973747B6D61782D6865696768743A393670783B6F766572666C6F773A6175746F7D2E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6C69';
wwv_flow_api.g_varchar2_table(48) := '6E6B3A686F7665727B746578742D6465636F726174696F6E3A756E6465726C696E657D2E666F732D416C6572742D2D70616765203A3A2D7765626B69742D7363726F6C6C6261727B77696474683A3870783B6865696768743A3870787D2E666F732D416C';
wwv_flow_api.g_varchar2_table(49) := '6572742D2D70616765203A3A2D7765626B69742D7363726F6C6C6261722D7468756D627B6261636B67726F756E642D636F6C6F723A7267626128302C302C302C2E3235297D2E666F732D416C6572742D2D70616765203A3A2D7765626B69742D7363726F';
wwv_flow_api.g_varchar2_table(50) := '6C6C6261722D747261636B7B6261636B67726F756E642D636F6C6F723A7267626128302C302C302C2E3035297D2E666F732D416C6572742D2D70616765202E666F732D416C6572742D7469746C657B646973706C61793A626C6F636B3B666F6E742D7765';
wwv_flow_api.g_varchar2_table(51) := '696768743A3730303B666F6E742D73697A653A312E3872656D3B6D617267696E2D626F74746F6D3A303B6D617267696E2D72696768743A313670787D2E666F732D416C6572742D2D70616765202E666F732D416C6572742D626F64797B6D617267696E2D';
wwv_flow_api.g_varchar2_table(52) := '72696768743A313670787D2E752D52544C202E666F732D416C6572742D2D70616765202E666F732D416C6572742D626F64792C2E752D52544C202E666F732D416C6572742D2D70616765202E666F732D416C6572742D7469746C657B6D617267696E2D72';
wwv_flow_api.g_varchar2_table(53) := '696768743A303B6D617267696E2D6C6566743A313670787D2E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6C6973747B6D617267696E3A347078203020303B70616464696E673A303B6C6973742D7374796C653A6E6F';
wwv_flow_api.g_varchar2_table(54) := '6E657D2E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6974656D7B70616464696E672D6C6566743A323070783B706F736974696F6E3A72656C61746976653B666F6E742D73697A653A313470783B6C696E652D686569';
wwv_flow_api.g_varchar2_table(55) := '6768743A323070783B6D617267696E2D626F74746F6D3A3470787D2E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6974656D3A6C6173742D6368696C647B6D617267696E2D626F74746F6D3A307D2E752D52544C202E';
wwv_flow_api.g_varchar2_table(56) := '666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6974656D7B70616464696E672D6C6566743A303B70616464696E672D72696768743A323070787D2E666F732D416C6572742D2D70616765202E612D4E6F74696669636174';
wwv_flow_api.g_varchar2_table(57) := '696F6E2D6974656D3A6265666F72657B636F6E74656E743A27273B706F736974696F6E3A6162736F6C7574653B6D617267696E3A3870783B746F703A303B6C6566743A303B77696474683A3470783B6865696768743A3470783B626F726465722D726164';
wwv_flow_api.g_varchar2_table(58) := '6975733A313030253B6261636B67726F756E642D636F6C6F723A7267626128302C302C302C2E35297D2E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6974656D202E612D427574746F6E2D2D6E6F7469666963617469';
wwv_flow_api.g_varchar2_table(59) := '6F6E7B70616464696E673A3270783B6F7061636974793A2E37353B766572746963616C2D616C69676E3A746F707D2E666F732D416C6572742D2D70616765202E68746D6C64624F72614572727B6D617267696E2D746F703A2E3872656D3B646973706C61';
wwv_flow_api.g_varchar2_table(60) := '793A626C6F636B3B666F6E742D73697A653A312E3172656D3B6C696E652D6865696768743A312E3672656D3B666F6E742D66616D696C793A274D656E6C6F272C27436F6E736F6C6173272C6D6F6E6F73706163652C73657269663B77686974652D737061';
wwv_flow_api.g_varchar2_table(61) := '63653A7072652D6C696E657D2E666F732D416C6572742D2D61636365737369626C6548656164696E67202E666F732D416C6572742D7469746C657B626F726465723A303B636C69703A726563742830203020302030293B6865696768743A3170783B6D61';
wwv_flow_api.g_varchar2_table(62) := '7267696E3A2D3170783B6F766572666C6F773A68696464656E3B70616464696E673A303B706F736974696F6E3A6162736F6C7574653B77696474683A3170787D2E666F732D416C6572742D2D72656D6F766548656164696E67202E666F732D416C657274';
wwv_flow_api.g_varchar2_table(63) := '2D7469746C657B646973706C61793A6E6F6E657D406D6564696120286D61782D77696474683A3438307078297B2E666F732D416C6572742D2D706167657B6D696E2D77696474683A303B6D61782D77696474683A6E6F6E657D2E666F732D416C6572742D';
wwv_flow_api.g_varchar2_table(64) := '2D70616765202E612D4E6F74696669636174696F6E2D6974656D7B666F6E742D73697A653A313270787D7D406D6564696120286D61782D77696474683A3736387078297B2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572';
wwv_flow_api.g_varchar2_table(65) := '742D7469746C657B666F6E742D73697A653A312E3872656D7D7D2E666F732D416C657274202E742D49636F6E2E69636F6E2D636C6F73653A6265666F72657B666F6E742D66616D696C793A22617065782D352D69636F6E2D666F6E74223B646973706C61';
wwv_flow_api.g_varchar2_table(66) := '793A696E6C696E652D626C6F636B3B766572746963616C2D616C69676E3A746F703B6C696E652D6865696768743A313670783B666F6E742D73697A653A313670783B636F6E74656E743A225C65306132227D2E666F7374722D746F702D63656E7465727B';
wwv_flow_api.g_varchar2_table(67) := '746F703A312E3672656D3B72696768743A303B77696474683A313030257D2E666F7374722D626F74746F6D2D63656E7465727B626F74746F6D3A312E3672656D3B72696768743A303B77696474683A313030257D2E666F7374722D746F702D7269676874';
wwv_flow_api.g_varchar2_table(68) := '7B746F703A312E3672656D3B72696768743A312E3672656D7D2E666F7374722D746F702D6C6566747B746F703A312E3672656D3B6C6566743A312E3672656D7D2E666F7374722D626F74746F6D2D72696768747B72696768743A312E3672656D3B626F74';
wwv_flow_api.g_varchar2_table(69) := '746F6D3A312E3672656D7D2E666F7374722D626F74746F6D2D6C6566747B626F74746F6D3A312E3672656D3B6C6566743A312E3672656D7D2E666F7374722D636F6E7461696E65727B706F736974696F6E3A66697865643B7A2D696E6465783A39393939';
wwv_flow_api.g_varchar2_table(70) := '39393B706F696E7465722D6576656E74733A6E6F6E657D2E666F7374722D636F6E7461696E65723E6469767B706F696E7465722D6576656E74733A6175746F7D2E666F7374722D636F6E7461696E65722E666F7374722D626F74746F6D2D63656E746572';
wwv_flow_api.g_varchar2_table(71) := '3E6469762C2E666F7374722D636F6E7461696E65722E666F7374722D746F702D63656E7465723E6469767B6D617267696E2D6C6566743A6175746F3B6D617267696E2D72696768743A6175746F7D2E666F7374722D70726F67726573737B706F73697469';
wwv_flow_api.g_varchar2_table(72) := '6F6E3A6162736F6C7574653B626F74746F6D3A303B6865696768743A3470783B6261636B67726F756E642D636F6C6F723A233030303B6F7061636974793A2E347D68746D6C3A6E6F74282E752D52544C29202E666F7374722D70726F67726573737B6C65';
wwv_flow_api.g_varchar2_table(73) := '66743A303B626F726465722D626F74746F6D2D6C6566742D7261646975733A2E3472656D7D68746D6C2E752D52544C202E666F7374722D70726F67726573737B72696768743A303B626F726465722D626F74746F6D2D72696768742D7261646975733A2E';
wwv_flow_api.g_varchar2_table(74) := '3472656D7D406D6564696120286D61782D77696474683A3438307078297B2E666F7374722D636F6E7461696E65727B6C6566743A312E3672656D3B72696768743A312E3672656D7D7D0A2F2A2320736F757263654D617070696E6755524C3D666F737472';
wwv_flow_api.g_varchar2_table(75) := '2E6373732E6D61702A2F';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(44243330981499750)
,p_plugin_id=>wwv_flow_api.id(50031193176975232)
,p_file_name=>'css/fostr.min.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A0A202A2052544C20737570706F72742073686F756C6420626520646F6E6520696E20637373206F6E6C792E20636C61737320752D52544C20657869737473206F6E2074686520626F6479207768656E206170657820697320696E2052544C206D6F64';
wwv_flow_api.g_varchar2_table(2) := '652E0A202A204E6F7465207468617420746869732073686F756C64206F6E6C792061666665637420656C656D656E74732077697468696E20746865206E6F74696669636174696F6E2C206E6F742074686520706F736974696F6E696E67206F6620746865';
wwv_flow_api.g_varchar2_table(3) := '2061637475616C206E6F74696669636174696F6E2E0A202A20546869732069732074616B656E2063617265206F66206279206120706C75672D696E2073657474696E67732E0A202A0A202A2F0A0A2F2A0A202A20466F7374720A202A20436F7079726967';
wwv_flow_api.g_varchar2_table(4) := '687420323032300A202A20417574686F72733A2053746566616E20446F6272650A202A200A202A204372656469747320666F722074686520626173652076657273696F6E20676F20746F3A2068747470733A2F2F6769746875622E636F6D2F436F646553';
wwv_flow_api.g_varchar2_table(5) := '6576656E2F746F617374720A202A204F726967696E616C20417574686F72733A204A6F686E20506170612C2048616E7320466AC3A46C6C656D61726B2C20616E642054696D2046657272656C6C2E0A202A204152494120537570706F72743A2047726574';
wwv_flow_api.g_varchar2_table(6) := '61204B7261667369670A202A200A202A20416C6C205269676874732052657365727665642E0A202A205573652C20726570726F64756374696F6E2C20646973747269627574696F6E2C20616E64206D6F64696669636174696F6E206F6620746869732063';
wwv_flow_api.g_varchar2_table(7) := '6F6465206973207375626A65637420746F20746865207465726D7320616E640A202A20636F6E646974696F6E73206F6620746865204D4954206C6963656E73652C20617661696C61626C6520617420687474703A2F2F7777772E6F70656E736F75726365';
wwv_flow_api.g_varchar2_table(8) := '2E6F72672F6C6963656E7365732F6D69742D6C6963656E73652E7068700A202A0A202A2050726F6A6563743A2068747470733A2F2F6769746875622E636F6D2F666F65782D6F70656E2D736F757263652F666F7374720A202A2F0A77696E646F772E666F';
wwv_flow_api.g_varchar2_table(9) := '737472203D202866756E6374696F6E2829207B0A0A2020202076617220746F61737454797065203D207B0A2020202020202020737563636573733A202773756363657373272C0A2020202020202020696E666F3A2027696E666F272C0A20202020202020';
wwv_flow_api.g_varchar2_table(10) := '207761726E696E673A20277761726E696E67272C0A20202020202020206572726F723A20276572726F72270A202020207D3B0A0A202020207661722069636F6E436C6173736573203D207B0A2020202020202020737563636573733A202266612D636865';
wwv_flow_api.g_varchar2_table(11) := '636B2D636972636C65222C0A2020202020202020696E666F3A202266612D696E666F2D636972636C65222C0A20202020202020207761726E696E673A202266612D6578636C616D6174696F6E2D747269616E676C65222C0A20202020202020206572726F';
wwv_flow_api.g_varchar2_table(12) := '723A202266612D74696D65732D636972636C65220A202020207D3B0A0A2020202076617220636F6E7461696E657273203D207B7D3B0A202020207661722070726576696F7573546F617374203D207B7D3B0A0A2020202066756E6374696F6E206E6F7469';
wwv_flow_api.g_varchar2_table(13) := '66795479706528747970652C206D6573736167652C207469746C6529207B0A202020202020202069662028747970656F66206D657373616765203D3D3D2027737472696E672729207B0A20202020202020202020202069662028217469746C6529207B0A';
wwv_flow_api.g_varchar2_table(14) := '202020202020202020202020202020207469746C65203D206D6573736167653B0A202020202020202020202020202020206D657373616765203D20756E646566696E65643B0A2020202020202020202020207D0A20202020202020202020202072657475';
wwv_flow_api.g_varchar2_table(15) := '726E206E6F74696679287B0A20202020202020202020202020202020747970653A20747970652C0A202020202020202020202020202020206D6573736167653A206D6573736167652C0A202020202020202020202020202020207469746C653A20746974';
wwv_flow_api.g_varchar2_table(16) := '6C650A2020202020202020202020207D293B0A20202020202020207D20656C73652069662028747970656F66206D657373616765203D3D3D20276F626A6563742729207B0A2020202020202020202020206D6573736167652E74797065203D2074797065';
wwv_flow_api.g_varchar2_table(17) := '3B0A20202020202020202020202072657475726E206E6F74696679286D657373616765293B0A20202020202020207D20656C7365207B0A202020202020202020202020636F6E736F6C652E6572726F722827666F737472206E6F74696669636174696F6E';
wwv_flow_api.g_varchar2_table(18) := '20226D6573736167652220706172616D657465722074797065206E6F7420737570706F727465642C206D757374206265206120737472696E67206F72206F626A65637427293B0A20202020202020207D0A202020207D0A0A2020202066756E6374696F6E';
wwv_flow_api.g_varchar2_table(19) := '2073756363657373286D6573736167652C207469746C6529207B0A20202020202020206E6F746966795479706528746F617374547970652E737563636573732C206D6573736167652C207469746C65293B0A202020207D0A0A2020202066756E6374696F';
wwv_flow_api.g_varchar2_table(20) := '6E207761726E696E67286D6573736167652C207469746C6529207B0A20202020202020206E6F746966795479706528746F617374547970652E7761726E696E672C206D6573736167652C207469746C65293B0A202020207D0A0A2020202066756E637469';
wwv_flow_api.g_varchar2_table(21) := '6F6E20696E666F286D6573736167652C207469746C6529207B0A20202020202020206E6F746966795479706528746F617374547970652E696E666F2C206D6573736167652C207469746C65293B0A202020207D0A0A2020202066756E6374696F6E206572';
wwv_flow_api.g_varchar2_table(22) := '726F72286D6573736167652C207469746C6529207B0A20202020202020206E6F746966795479706528746F617374547970652E6572726F722C206D6573736167652C207469746C65293B0A202020207D0A0A2020202066756E6374696F6E20636C656172';
wwv_flow_api.g_varchar2_table(23) := '416C6C2829207B0A20202020202020202428272E27202B20676574436F6E7461696E6572436C6173732829292E6368696C6472656E28292E72656D6F766528293B0A202020207D0A0A202020202F2F20696E7465726E616C2066756E6374696F6E730A0A';
wwv_flow_api.g_varchar2_table(24) := '2020202066756E6374696F6E20676574436F6E7461696E6572436C6173732829207B0A202020202020202072657475726E2027666F7374722D636F6E7461696E6572273B0A202020207D0A0A2020202066756E6374696F6E20676574436F6E7461696E65';
wwv_flow_api.g_varchar2_table(25) := '7228706F736974696F6E29207B0A0A202020202020202066756E6374696F6E20637265617465436F6E7461696E657228706F736974696F6E29207B0A2020202020202020202020207661722024636F6E7461696E6572203D202428273C6469762F3E2729';
wwv_flow_api.g_varchar2_table(26) := '2E616464436C6173732827666F7374722D27202B20706F736974696F6E292E616464436C61737328676574436F6E7461696E6572436C6173732829293B0A202020202020202020202020242827626F647927292E617070656E642824636F6E7461696E65';
wwv_flow_api.g_varchar2_table(27) := '72293B0A202020202020202020202020636F6E7461696E6572735B706F736974696F6E5D203D2024636F6E7461696E65723B0A20202020202020202020202072657475726E2024636F6E7461696E65723B0A20202020202020207D0A0A20202020202020';
wwv_flow_api.g_varchar2_table(28) := '2072657475726E20636F6E7461696E6572735B706F736974696F6E5D207C7C20637265617465436F6E7461696E657228706F736974696F6E293B0A202020207D0A0A2020202066756E6374696F6E2067657444656661756C74732829207B0A2020202020';
wwv_flow_api.g_varchar2_table(29) := '20202072657475726E207B0A2020202020202020202020206469736D6973733A205B276F6E436C69636B272C20276F6E427574746F6E275D2C202F2F207768656E20746F206469736D69737320746865206E6F74696669636174696F6E0A202020202020';
wwv_flow_api.g_varchar2_table(30) := '2020202020206469736D69737341667465723A206E756C6C2C202F2F2061206E756D62657220696E206D696C6C697365636F6E647320616674657220776869636820746865206E6F74696669636174696F6E2073686F756C64206265206175746F6D6174';
wwv_flow_api.g_varchar2_table(31) := '6963616C6C792072656D6F7665642E20686F766572696E67206F7220636C69636B696E6720746865206E6F74696669636174696F6E2073746F70732074686973206576656E740A2020202020202020202020206E65776573744F6E546F703A2074727565';
wwv_flow_api.g_varchar2_table(32) := '2C202F2F2061646420746F2074686520746F70206F6620746865206C6973740A20202020202020202020202070726576656E744475706C6963617465733A2066616C73652C202F2F20646F206E6F742073686F7720746865206E6F74696669636174696F';
wwv_flow_api.g_varchar2_table(33) := '6E20696620697420686173207468652073616D65207469746C6520616E64206D65737361676520617320746865206C617374206F6E6520616E6420696620746865206C617374206F6E65206973207374696C6C2076697369626C650A2020202020202020';
wwv_flow_api.g_varchar2_table(34) := '2020202065736361706548746D6C3A20747275652C202F2F207768657468657220746F2065736361706520746865207469746C6520616E64206D6573736167650A202020202020202020202020706F736974696F6E3A2027746F702D7269676874272C20';
wwv_flow_api.g_varchar2_table(35) := '2F2F206F6E65206F6620363A205B746F707C626F74746F6D5D2D5B72696768747C63656E7465727C6C6566745D0A20202020202020202020202069636F6E436C6173733A206E756C6C2C202F2F207768656E206C65667420746F206E756C6C2C20697420';
wwv_flow_api.g_varchar2_table(36) := '77696C6C2062652064656661756C74656420746F2074686520636F72726573706F6E64696E672069636F6E2066726F6D2069636F6E436C61737365730A202020202020202020202020636C656172416C6C3A2066616C7365202F2F207472756520746F20';
wwv_flow_api.g_varchar2_table(37) := '636C65617220616C6C206E6F74696669636174696F6E732066697273740A20202020202020207D3B0A202020207D0A0A2020202066756E6374696F6E206765744F7074696F6E732829207B0A202020202020202072657475726E20242E657874656E6428';
wwv_flow_api.g_varchar2_table(38) := '7B7D2C2067657444656661756C747328292C20666F7374722E6F7074696F6E73293B0A202020207D0A0A2020202066756E6374696F6E206E6F74696679286D617029207B0A0A2020202020202020766172206F7074696F6E73203D20242E657874656E64';
wwv_flow_api.g_varchar2_table(39) := '287B7D2C206765744F7074696F6E7328292C206D6170293B0A20202020202020207661722024636F6E7461696E6572203D20676574436F6E7461696E6572286F7074696F6E732E706F736974696F6E293B0A0A2020202020202020766172206469736D69';
wwv_flow_api.g_varchar2_table(40) := '73734F6E436C69636B203D206F7074696F6E732E6469736D6973732E696E636C7564657328276F6E436C69636B27293B0A2020202020202020766172206469736D6973734F6E427574746F6E203D206F7074696F6E732E6469736D6973732E696E636C75';
wwv_flow_api.g_varchar2_table(41) := '64657328276F6E427574746F6E27293B0A0A20202020202020202F2A0A20202020202020203C64697620636C6173733D22666F732D416C65727420666F732D416C6572742D2D686F72697A6F6E74616C20666F732D416C6572742D2D7061676520666F73';
wwv_flow_api.g_varchar2_table(42) := '2D416C6572742D2D737563636573732220726F6C653D22616C657274223E0A2020202020202020202020203C64697620636C6173733D22666F732D416C6572742D77726170223E0A202020202020202020202020202020203C64697620636C6173733D22';
wwv_flow_api.g_varchar2_table(43) := '666F732D416C6572742D69636F6E223E0A20202020202020202020202020202020202020203C7370616E20636C6173733D22742D49636F6E2066612066612D636865636B2D636972636C65223E3C2F7370616E3E0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(44) := '203C2F6469763E0A202020202020202020202020202020203C64697620636C6173733D22666F732D416C6572742D636F6E74656E74223E0A20202020202020202020202020202020202020203C683220636C6173733D22666F732D416C6572742D746974';
wwv_flow_api.g_varchar2_table(45) := '6C65223E3C2F68323E0A20202020202020202020202020202020202020203C64697620636C6173733D22666F732D416C6572742D626F6479223E3C2F6469763E0A202020202020202020202020202020203C2F6469763E0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(46) := '202020203C64697620636C6173733D22666F732D416C6572742D627574746F6E73223E0A20202020202020202020202020202020202020203C627574746F6E20636C6173733D22742D427574746F6E20742D427574746F6E2D2D6E6F554920742D427574';
wwv_flow_api.g_varchar2_table(47) := '746F6E2D2D69636F6E20742D427574746F6E2D2D636C6F7365416C6572742220747970653D22627574746F6E22207469746C653D22436C6F7365204E6F74696669636174696F6E223E3C7370616E20636C6173733D22742D49636F6E2069636F6E2D636C';
wwv_flow_api.g_varchar2_table(48) := '6F7365223E3C2F7370616E3E3C2F627574746F6E3E0A202020202020202020202020202020203C2F6469763E0A2020202020202020202020203C2F6469763E0A20202020202020203C2F6469763E0A20202020202020202A2F0A0A202020202020202076';
wwv_flow_api.g_varchar2_table(49) := '61722074797065436C617373203D207B0A2020202020202020202020202273756363657373223A2022666F732D416C6572742D2D73756363657373222C0A202020202020202020202020226572726F72223A2022666F732D416C6572742D2D64616E6765';
wwv_flow_api.g_varchar2_table(50) := '72222C0A202020202020202020202020227761726E696E67223A2022666F732D416C6572742D2D7761726E696E67222C0A20202020202020202020202022696E666F223A2022666F732D416C6572742D2D696E666F220A20202020202020207D3B0A0A20';
wwv_flow_api.g_varchar2_table(51) := '202020202020207661722024746F617374456C656D656E74203D202428273C64697620636C6173733D22666F732D416C65727420666F732D416C6572742D2D686F72697A6F6E74616C20666F732D416C6572742D2D706167652027202B2074797065436C';
wwv_flow_api.g_varchar2_table(52) := '6173735B6F7074696F6E732E747970655D202B20272220726F6C653D22616C657274223E3C2F6469763E27293B0A20202020202020207661722024746F61737457726170203D202428273C64697620636C6173733D22666F732D416C6572742D77726170';
wwv_flow_api.g_varchar2_table(53) := '223E27293B0A2020202020202020766172202469636F6E57726170203D202428273C64697620636C6173733D22666F732D416C6572742D69636F6E223E3C2F6469763E27293B0A2020202020202020766172202469636F6E456C656D203D202428273C73';
wwv_flow_api.g_varchar2_table(54) := '70616E20636C6173733D22742D49636F6E2066612027202B20286F7074696F6E732E69636F6E436C617373207C7C2069636F6E436C61737365735B6F7074696F6E732E747970655D29202B2027223E3C2F7370616E3E27293B0A20202020202020207661';
wwv_flow_api.g_varchar2_table(55) := '722024636F6E74656E74456C656D203D202428273C64697620636C6173733D22666F732D416C6572742D636F6E74656E74223E3C2F6469763E27293B0A202020202020202076617220247469746C65456C656D656E74203D202428273C683220636C6173';
wwv_flow_api.g_varchar2_table(56) := '733D22666F732D416C6572742D7469746C65223E3C2F68323E27293B0A202020202020202076617220246D657373616765456C656D656E74203D202428273C64697620636C6173733D22666F732D416C6572742D626F6479223E3C2F6469763E27293B0A';
wwv_flow_api.g_varchar2_table(57) := '20202020202020207661722024627574746F6E57726170706572203D202428273C64697620636C6173733D22666F732D416C6572742D627574746F6E73223E3C2F6469763E27293B0A20202020202020207661722024636C6F7365456C656D656E743B0A';
wwv_flow_api.g_varchar2_table(58) := '0A2020202020202020696620286469736D6973734F6E427574746F6E29207B0A20202020202020202020202024636C6F7365456C656D656E74203D202428273C627574746F6E20636C6173733D22742D427574746F6E20742D427574746F6E2D2D6E6F55';
wwv_flow_api.g_varchar2_table(59) := '4920742D427574746F6E2D2D69636F6E20742D427574746F6E2D2D636C6F7365416C6572742220747970653D22627574746F6E22207469746C653D22436C6F7365204E6F74696669636174696F6E223E3C7370616E20636C6173733D22742D49636F6E20';
wwv_flow_api.g_varchar2_table(60) := '69636F6E2D636C6F7365223E3C2F7370616E3E3C2F627574746F6E3E27293B0A20202020202020207D0A0A202020202020202024746F617374456C656D656E742E617070656E642824746F61737457726170293B0A202020202020202024746F61737457';
wwv_flow_api.g_varchar2_table(61) := '7261702E617070656E64282469636F6E57726170293B0A20202020202020202469636F6E577261702E617070656E64282469636F6E456C656D293B0A202020202020202024746F617374577261702E617070656E642824636F6E74656E74456C656D293B';
wwv_flow_api.g_varchar2_table(62) := '0A202020202020202024636F6E74656E74456C656D2E617070656E6428247469746C65456C656D656E74293B0A202020202020202024636F6E74656E74456C656D2E617070656E6428246D657373616765456C656D656E74293B0A202020202020202024';
wwv_flow_api.g_varchar2_table(63) := '746F617374577261702E617070656E642824627574746F6E57726170706572293B0A0A2020202020202020696620286469736D6973734F6E427574746F6E29207B0A20202020202020202020202024627574746F6E577261707065722E617070656E6428';
wwv_flow_api.g_varchar2_table(64) := '24636C6F7365456C656D656E74293B0A20202020202020207D0A0A20202020202020202F2F2073657474696E6720746865207469746C650A2020202020202020766172207469746C65203D206F7074696F6E732E7469746C653B0A202020202020202069';
wwv_flow_api.g_varchar2_table(65) := '6620287469746C6529207B0A202020202020202020202020696620286F7074696F6E732E65736361706548746D6C29207B0A202020202020202020202020202020207469746C65203D20617065782E7574696C2E65736361706548544D4C287469746C65';
wwv_flow_api.g_varchar2_table(66) := '293B0A2020202020202020202020207D0A202020202020202020202020247469746C65456C656D656E742E617070656E64287469746C65293B0A20202020202020207D0A0A20202020202020202F2F73657474696E6720746865206D6573736167650A20';
wwv_flow_api.g_varchar2_table(67) := '20202020202020766172206D657373616765203D206F7074696F6E732E6D6573736167653B0A2020202020202020696620286D65737361676529207B0A202020202020202020202020696620286F7074696F6E732E65736361706548746D6C29207B0A20';
wwv_flow_api.g_varchar2_table(68) := '2020202020202020202020202020206D657373616765203D20617065782E7574696C2E65736361706548544D4C286D657373616765293B0A2020202020202020202020207D0A202020202020202020202020246D657373616765456C656D656E742E6170';
wwv_flow_api.g_varchar2_table(69) := '70656E64286D657373616765293B0A20202020202020207D0A0A20202020202020202F2F2061766F6964696E67206475706C6963617465732C20627574206F6E6C7920636F6E7365637574697665206F6E65730A2020202020202020696620286F707469';
wwv_flow_api.g_varchar2_table(70) := '6F6E732E70726576656E744475706C6963617465732026262070726576696F7573546F6173742026262070726576696F7573546F6173742E24656C656D2026262070726576696F7573546F6173742E24656C656D2E697328273A76697369626C65272929';
wwv_flow_api.g_varchar2_table(71) := '207B0A2020202020202020202020206966202870726576696F7573546F6173742E7469746C65203D3D207469746C652026262070726576696F7573546F6173742E6D657373616765203D3D206D65737361676529207B0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(72) := '20202072657475726E3B0A2020202020202020202020207D0A20202020202020207D0A0A202020202020202070726576696F7573546F617374203D207B0A20202020202020202020202024656C656D3A2024746F617374456C656D656E742C0A20202020';
wwv_flow_api.g_varchar2_table(73) := '20202020202020207469746C653A207469746C652C0A2020202020202020202020206D6573736167653A206D6573736167650A20202020202020207D3B0A0A20202020202020202F2F206F7074696F6E616C6C7920636C65617220616C6C206D65737361';
wwv_flow_api.g_varchar2_table(74) := '6765732066697273740A2020202020202020696620286F7074696F6E732E636C656172416C6C29207B0A202020202020202020202020636C656172416C6C28293B0A20202020202020207D0A20202020202020202F2F206164647320746865206E6F7469';
wwv_flow_api.g_varchar2_table(75) := '6669636174696F6E20746F2074686520636F6E7461696E65720A2020202020202020696620286F7074696F6E732E6E65776573744F6E546F7029207B0A20202020202020202020202024636F6E7461696E65722E70726570656E642824746F617374456C';
wwv_flow_api.g_varchar2_table(76) := '656D656E74293B0A20202020202020207D20656C7365207B0A20202020202020202020202024636F6E7461696E65722E617070656E642824746F617374456C656D656E74293B0A20202020202020207D0A0A20202020202020202F2F2073657474696E67';
wwv_flow_api.g_varchar2_table(77) := '2074686520636F727265637420415249412076616C75650A2020202020202020766172206172696156616C75653B0A202020202020202073776974636820286F7074696F6E732E7479706529207B0A202020202020202020202020636173652027737563';
wwv_flow_api.g_varchar2_table(78) := '63657373273A0A202020202020202020202020636173652027696E666F273A0A202020202020202020202020202020206172696156616C7565203D2027706F6C697465273B0A20202020202020202020202020202020627265616B3B0A20202020202020';
wwv_flow_api.g_varchar2_table(79) := '202020202064656661756C743A0A202020202020202020202020202020206172696156616C7565203D2027617373657274697665273B0A20202020202020207D0A202020202020202024746F617374456C656D656E742E617474722827617269612D6C69';
wwv_flow_api.g_varchar2_table(80) := '7665272C206172696156616C7565293B0A0A20202020202020202F2F73657474696E672074696D657220616E642070726F6772657373206261720A2020202020202020766172202470726F6772657373456C656D656E74203D202428273C6469762F3E27';
wwv_flow_api.g_varchar2_table(81) := '293B0A2020202020202020696620286F7074696F6E732E6469736D6973734166746572203E203029207B0A2020202020202020202020202470726F6772657373456C656D656E742E616464436C6173732827666F7374722D70726F677265737327293B0A';
wwv_flow_api.g_varchar2_table(82) := '20202020202020202020202024746F617374456C656D656E742E617070656E64282470726F6772657373456C656D656E74293B0A0A2020202020202020202020207661722074696D656F75744964203D2073657454696D656F75742866756E6374696F6E';
wwv_flow_api.g_varchar2_table(83) := '2829207B0A2020202020202020202020202020202024746F617374456C656D656E742E72656D6F766528293B0A2020202020202020202020207D2C206F7074696F6E732E6469736D6973734166746572293B0A2020202020202020202020207661722070';
wwv_flow_api.g_varchar2_table(84) := '726F67726573735374617274416E696D44656C6179203D203130303B0A0A2020202020202020202020202470726F6772657373456C656D656E742E637373287B0A20202020202020202020202020202020277769647468273A202731303025272C0A2020';
wwv_flow_api.g_varchar2_table(85) := '2020202020202020202020202020277472616E736974696F6E273A202777696474682027202B2028286F7074696F6E732E6469736D6973734166746572202D2070726F67726573735374617274416E696D44656C6179292F3130303029202B202773206C';
wwv_flow_api.g_varchar2_table(86) := '696E656172270A2020202020202020202020207D293B0A20202020202020202020202073657454696D656F75742866756E6374696F6E28297B0A202020202020202020202020202020202470726F6772657373456C656D656E742E637373282777696474';
wwv_flow_api.g_varchar2_table(87) := '68272C20273027293B0A2020202020202020202020207D2C2070726F67726573735374617274416E696D44656C6179293B0A0A2020202020202020202020202F2F206F6E20686F766572206F7220636C69636B2C2072656D6F7665207468652074696D65';
wwv_flow_api.g_varchar2_table(88) := '7220616E642070726F6772657373206261720A20202020202020202020202024746F617374456C656D656E742E6F6E28276D6F7573656F76657220636C69636B272C2066756E6374696F6E2829207B0A20202020202020202020202020202020636C6561';
wwv_flow_api.g_varchar2_table(89) := '7254696D656F75742874696D656F75744964293B0A202020202020202020202020202020202470726F6772657373456C656D656E742E72656D6F766528293B0A2020202020202020202020207D293B0A20202020202020207D0A0A20202020202020202F';
wwv_flow_api.g_varchar2_table(90) := '2F68616E646C696E6720616E79206576656E74730A2020202020202020696620286469736D6973734F6E436C69636B29207B0A20202020202020202020202024746F617374456C656D656E742E6F6E2827636C69636B272C2066756E6374696F6E282920';
wwv_flow_api.g_varchar2_table(91) := '7B0A202020202020202020202020202020202F2F206F6E6C792072656D6F766520696620697420636F6E7461696E73206E6F206163746976652073656C656374696F6E0A202020202020202020202020202020207661722073656C656374696F6E203D20';
wwv_flow_api.g_varchar2_table(92) := '77696E646F772E67657453656C656374696F6E28293B0A202020202020202020202020202020206966282073656C656374696F6E202626200A202020202020202020202020202020202020202073656C656374696F6E2E74797065203D3D202752616E67';
wwv_flow_api.g_varchar2_table(93) := '65272026260A202020202020202020202020202020202020202073656C656374696F6E2E616E63686F724E6F64652026260A2020202020202020202020202020202020202020242873656C656374696F6E2E616E63686F724E6F64652C2024746F617374';
wwv_flow_api.g_varchar2_table(94) := '456C656D656E74292E6C656E677468203E2030297B0A2020202020202020202020202020202020202020200A202020202020202020202020202020202020202072657475726E3B0A202020202020202020202020202020207D0A20202020202020202020';
wwv_flow_api.g_varchar2_table(95) := '20202020202024746F617374456C656D656E742E72656D6F766528293B0A2020202020202020202020207D293B0A20202020202020207D0A0A2020202020202020696620286469736D6973734F6E427574746F6E29207B0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(96) := '24636C6F7365456C656D656E742E6F6E2827636C69636B272C2066756E6374696F6E2829207B0A2020202020202020202020202020202024746F617374456C656D656E742E72656D6F766528293B0A2020202020202020202020207D293B0A2020202020';
wwv_flow_api.g_varchar2_table(97) := '2020207D0A0A20202020202020202F2F20706572686170732074686520646576656C6F7065722077616E747320746F20646F20736F6D657468696E67206164646974696F6E616C6C79207768656E20746865206E6F74696669636174696F6E2069732063';
wwv_flow_api.g_varchar2_table(98) := '6C69636B65640A202020202020202069662028747970656F66206F7074696F6E732E6F6E636C69636B203D3D3D202766756E6374696F6E2729207B0A20202020202020202020202024746F617374456C656D656E742E6F6E2827636C69636B272C206F70';
wwv_flow_api.g_varchar2_table(99) := '74696F6E732E6F6E636C69636B293B0A202020202020202020202020696620286469736D6973734F6E427574746F6E292024636C6F7365456C656D656E742E6F6E2827636C69636B272C206F7074696F6E732E6F6E636C69636B293B0A20202020202020';
wwv_flow_api.g_varchar2_table(100) := '207D0A0A202020202020202072657475726E2024746F617374456C656D656E743B0A202020207D0A0A2020202072657475726E207B0A2020202020202020737563636573733A20737563636573732C0A2020202020202020696E666F3A20696E666F2C0A';
wwv_flow_api.g_varchar2_table(101) := '20202020202020207761726E696E673A207761726E696E672C0A20202020202020206572726F723A206572726F722C0A2020202020202020636C656172416C6C3A20636C656172416C6C2C0A202020202020202076657273696F6E3A202732302E312E30';
wwv_flow_api.g_varchar2_table(102) := '270A202020207D3B0A0A7D2928293B';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(44317473815554813)
,p_plugin_id=>wwv_flow_api.id(50031193176975232)
,p_file_name=>'js/fostr.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A0A0A094E6F7465730A09092A206162736F6C757465206C65667420616E642072696768742076616C7565732073686F756C64206E6F7720626520706C61636573206F6E2074686520636F6E7461696E657220656C656D656E742C206E6F7420746865';
wwv_flow_api.g_varchar2_table(2) := '20696E646976696475616C206E6F74696669636174696F6E730A0A2A2F0A2F2A2A0A202A20436F6C6F72697A6564204261636B67726F756E640A202A2F0A2E666F732D416C6572742D2D686F72697A6F6E74616C207B0A2020626F726465722D72616469';
wwv_flow_api.g_varchar2_table(3) := '75733A203270783B0A7D0A2E666F732D416C6572742D69636F6E202E742D49636F6E207B0A2020636F6C6F723A20234646463B0A7D0A2F2A2A0A20202A204D6F6469666965723A205761726E696E670A20202A2F0A2E666F732D416C6572742D2D776172';
wwv_flow_api.g_varchar2_table(4) := '6E696E67202E666F732D416C6572742D69636F6E202E742D49636F6E207B0A2020636F6C6F723A20236662636634613B0A7D0A2E666F732D416C6572742D2D7761726E696E672E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C';
wwv_flow_api.g_varchar2_table(5) := '6572742D69636F6E207B0A20206261636B67726F756E642D636F6C6F723A2072676261283235312C203230372C2037342C20302E3135293B0A7D0A2F2A2A0A20202A204D6F6469666965723A20537563636573730A20202A2F0A2E666F732D416C657274';
wwv_flow_api.g_varchar2_table(6) := '2D2D73756363657373202E666F732D416C6572742D69636F6E202E742D49636F6E207B0A2020636F6C6F723A20233342414132433B0A7D0A2E666F732D416C6572742D2D737563636573732E666F732D416C6572742D2D686F72697A6F6E74616C202E66';
wwv_flow_api.g_varchar2_table(7) := '6F732D416C6572742D69636F6E207B0A20206261636B67726F756E642D636F6C6F723A20726762612835392C203137302C2034342C20302E3135293B0A7D0A2F2A2A0A20202A204D6F6469666965723A20496E666F726D6174696F6E0A20202A2F0A2E66';
wwv_flow_api.g_varchar2_table(8) := '6F732D416C6572742D2D696E666F202E666F732D416C6572742D69636F6E202E742D49636F6E207B0A2020636F6C6F723A20233030373664663B0A7D0A2E666F732D416C6572742D2D696E666F2E666F732D416C6572742D2D686F72697A6F6E74616C20';
wwv_flow_api.g_varchar2_table(9) := '2E666F732D416C6572742D69636F6E207B0A20206261636B67726F756E642D636F6C6F723A207267626128302C203131382C203232332C20302E3135293B0A7D0A2F2A2A0A20202A204D6F6469666965723A20537563636573730A20202A2F0A2E666F73';
wwv_flow_api.g_varchar2_table(10) := '2D416C6572742D2D64616E676572202E666F732D416C6572742D69636F6E202E742D49636F6E207B0A2020636F6C6F723A20236634343333363B0A7D0A2E666F732D416C6572742D2D64616E6765722E666F732D416C6572742D2D686F72697A6F6E7461';
wwv_flow_api.g_varchar2_table(11) := '6C202E666F732D416C6572742D69636F6E207B0A20206261636B67726F756E642D636F6C6F723A2072676261283234342C2036372C2035342C20302E3135293B0A7D0A2E666F732D416C6572742D2D686F72697A6F6E74616C207B0A20206261636B6772';
wwv_flow_api.g_varchar2_table(12) := '6F756E642D636F6C6F723A20236666666666663B0A2020636F6C6F723A20233236323632363B0A7D0A2F2A0A2E666F732D416C6572742D2D64616E6765727B0A094062673A206C69676874656E2840675F44616E6765722D42472C20343025293B0A0962';
wwv_flow_api.g_varchar2_table(13) := '61636B67726F756E642D636F6C6F723A204062673B0A09636F6C6F723A206661646528636F6E7472617374284062672C2064657361747572617465286461726B656E284062672C202031303025292C2031303025292C2064657361747572617465286C69';
wwv_flow_api.g_varchar2_table(14) := '676874656E284062672C202031303025292C2035302529292C2031303025293B0A7D0A2E666F732D416C6572742D2D696E666F207B0A094062673A206C69676874656E2840675F496E666F2D42472C20353525293B0A096261636B67726F756E642D636F';
wwv_flow_api.g_varchar2_table(15) := '6C6F723A204062673B0A09636F6C6F723A206661646528636F6E7472617374284062672C2064657361747572617465286461726B656E284062672C202031303025292C2031303025292C2064657361747572617465286C69676874656E284062672C2020';
wwv_flow_api.g_varchar2_table(16) := '31303025292C2035302529292C2031303025293B0A7D0A2A2F0A2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D73756363657373207B0A20206261636B67726F756E642D636F6C6F723A20726762612835392C203137302C203434';
wwv_flow_api.g_varchar2_table(17) := '2C20302E39293B0A2020636F6C6F723A20234646463B0A7D0A2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D73756363657373202E666F732D416C6572742D69636F6E207B0A20206261636B67726F756E642D636F6C6F723A2074';
wwv_flow_api.g_varchar2_table(18) := '72616E73706172656E743B0A2020636F6C6F723A20234646463B0A7D0A2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D73756363657373202E666F732D416C6572742D69636F6E202E742D49636F6E207B0A2020636F6C6F723A20';
wwv_flow_api.g_varchar2_table(19) := '696E68657269743B0A7D0A2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D73756363657373202E742D427574746F6E2D2D636C6F7365416C657274207B0A2020636F6C6F723A20234646462021696D706F7274616E743B0A7D0A2E';
wwv_flow_api.g_varchar2_table(20) := '666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E67207B0A20206261636B67726F756E642D636F6C6F723A20236662636634613B0A2020636F6C6F723A20233434333430323B0A7D0A2E666F732D416C6572742D2D7061';
wwv_flow_api.g_varchar2_table(21) := '67652E666F732D416C6572742D2D7761726E696E67202E666F732D416C6572742D69636F6E207B0A20206261636B67726F756E642D636F6C6F723A207472616E73706172656E743B0A2020636F6C6F723A20233434333430323B0A7D0A2E666F732D416C';
wwv_flow_api.g_varchar2_table(22) := '6572742D2D706167652E666F732D416C6572742D2D7761726E696E67202E666F732D416C6572742D69636F6E202E742D49636F6E207B0A2020636F6C6F723A20696E68657269743B0A7D0A2E666F732D416C6572742D2D706167652E666F732D416C6572';
wwv_flow_api.g_varchar2_table(23) := '742D2D7761726E696E67202E742D427574746F6E2D2D636C6F7365416C657274207B0A2020636F6C6F723A20234646462021696D706F7274616E743B0A7D0A2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D696E666F207B0A2020';
wwv_flow_api.g_varchar2_table(24) := '6261636B67726F756E642D636F6C6F723A20233030373664663B0A2020636F6C6F723A20234646463B0A7D0A2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D696E666F202E666F732D416C6572742D69636F6E207B0A2020626163';
wwv_flow_api.g_varchar2_table(25) := '6B67726F756E642D636F6C6F723A207472616E73706172656E743B0A2020636F6C6F723A20234646463B0A7D0A2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D696E666F202E666F732D416C6572742D69636F6E202E742D49636F';
wwv_flow_api.g_varchar2_table(26) := '6E207B0A2020636F6C6F723A20696E68657269743B0A7D0A2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D696E666F202E742D427574746F6E2D2D636C6F7365416C657274207B0A2020636F6C6F723A20234646462021696D706F';
wwv_flow_api.g_varchar2_table(27) := '7274616E743B0A7D0A2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D64616E676572207B0A20206261636B67726F756E642D636F6C6F723A20236634343333363B0A2020636F6C6F723A20234646463B0A7D0A2E666F732D416C65';
wwv_flow_api.g_varchar2_table(28) := '72742D2D706167652E666F732D416C6572742D2D64616E676572202E666F732D416C6572742D69636F6E207B0A20206261636B67726F756E642D636F6C6F723A207472616E73706172656E743B0A2020636F6C6F723A20234646463B0A7D0A2E666F732D';
wwv_flow_api.g_varchar2_table(29) := '416C6572742D2D706167652E666F732D416C6572742D2D64616E676572202E666F732D416C6572742D69636F6E202E742D49636F6E207B0A2020636F6C6F723A20696E68657269743B0A7D0A2E666F732D416C6572742D2D706167652E666F732D416C65';
wwv_flow_api.g_varchar2_table(30) := '72742D2D64616E676572202E742D427574746F6E2D2D636C6F7365416C657274207B0A2020636F6C6F723A20234646462021696D706F7274616E743B0A7D0A2F2A20486F72697A6F6E74616C20416C657274203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D';
wwv_flow_api.g_varchar2_table(31) := '3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F0A2E666F732D416C6572742D2D686F72697A6F6E74616C207B0A20206D617267696E2D626F74746F';
wwv_flow_api.g_varchar2_table(32) := '6D3A20312E3672656D3B0A2020706F736974696F6E3A2072656C61746976653B0A7D0A2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D77726170207B0A2020646973706C61793A20666C65783B0A2020666C65782D';
wwv_flow_api.g_varchar2_table(33) := '646972656374696F6E3A20726F773B0A7D0A2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D69636F6E207B0A202070616464696E673A203020313670783B0A2020666C65782D736872696E6B3A20303B0A20206469';
wwv_flow_api.g_varchar2_table(34) := '73706C61793A20666C65783B0A2020616C69676E2D6974656D733A2063656E7465723B0A7D0A2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D636F6E74656E74207B0A202070616464696E673A20313670783B0A20';
wwv_flow_api.g_varchar2_table(35) := '20666C65783A203120303B0A2020646973706C61793A20666C65783B0A2020666C65782D646972656374696F6E3A20636F6C756D6E3B0A20206A7573746966792D636F6E74656E743A2063656E7465723B0A7D0A2E666F732D416C6572742D2D686F7269';
wwv_flow_api.g_varchar2_table(36) := '7A6F6E74616C202E666F732D416C6572742D627574746F6E73207B0A2020666C65782D736872696E6B3A20303B0A2020746578742D616C69676E3A2072696768743B0A202077686974652D73706163653A206E6F777261703B0A202070616464696E672D';
wwv_flow_api.g_varchar2_table(37) := '72696768743A20312E3672656D3B0A2020646973706C61793A20666C65783B0A2020616C69676E2D6974656D733A2063656E7465723B0A7D0A2E752D52544C202E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D6275';
wwv_flow_api.g_varchar2_table(38) := '74746F6E73207B0A202070616464696E672D72696768743A20303B0A202070616464696E672D6C6566743A20312E3672656D3B0A7D0A2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D627574746F6E733A656D7074';
wwv_flow_api.g_varchar2_table(39) := '79207B0A2020646973706C61793A206E6F6E653B0A7D0A2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D7469746C65207B0A2020666F6E742D73697A653A203272656D3B0A20206C696E652D6865696768743A2032';
wwv_flow_api.g_varchar2_table(40) := '2E3472656D3B0A20206D617267696E2D626F74746F6D3A20303B0A7D0A2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D626F64793A656D707479207B0A2020646973706C61793A206E6F6E653B0A7D0A2E666F732D';
wwv_flow_api.g_varchar2_table(41) := '416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D69636F6E202E742D49636F6E207B0A2020666F6E742D73697A653A20333270783B0A202077696474683A20333270783B0A2020746578742D616C69676E3A2063656E7465723B0A';
wwv_flow_api.g_varchar2_table(42) := '20206865696768743A20333270783B0A20206C696E652D6865696768743A20313B0A7D0A2F2A203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D';
wwv_flow_api.g_varchar2_table(43) := '3D3D3D3D3D3D3D3D3D3D3D3D3D20436F6D6D6F6E2050726F70657274696573203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D';
wwv_flow_api.g_varchar2_table(44) := '3D3D3D3D3D3D202A2F0A2E666F732D416C6572742D2D686F72697A6F6E74616C207B0A2020626F726465723A2031707820736F6C6964207267626128302C20302C20302C20302E31293B0A2020626F782D736861646F773A20302032707820347078202D';
wwv_flow_api.g_varchar2_table(45) := '327078207267626128302C20302C20302C20302E303735293B0A7D0A2E666F732D416C6572742D2D6E6F49636F6E2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D69636F6E207B0A2020646973706C61793A206E6F';
wwv_flow_api.g_varchar2_table(46) := '6E652021696D706F7274616E743B0A7D0A2E666F732D416C6572742D2D6E6F49636F6E202E666F732D416C6572742D69636F6E202E742D49636F6E207B0A2020646973706C61793A206E6F6E653B0A7D0A2E742D426F64792D616C657274207B0A20206D';
wwv_flow_api.g_varchar2_table(47) := '617267696E3A20303B0A7D0A2E742D426F64792D616C657274202E666F732D416C657274207B0A20206D617267696E2D626F74746F6D3A20303B0A7D0A2F2A2050616765204E6F74696669636174696F6E202853756363657373206F72204D6573736167';
wwv_flow_api.g_varchar2_table(48) := '6529203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F0A2E666F732D416C6572742D2D70616765207B0A';
wwv_flow_api.g_varchar2_table(49) := '20207472616E736974696F6E3A20302E327320656173652D6F75743B0A20206D61782D77696474683A2036343070783B0A20206D696E2D77696474683A2033323070783B0A20202F2A706F736974696F6E3A2066697865643B20746F703A20312E367265';
wwv_flow_api.g_varchar2_table(50) := '6D3B2072696768743A20312E3672656D3B2A2F0A20207A2D696E6465783A20313030303B0A2020626F726465722D77696474683A20303B0A2020626F782D736861646F773A20302030203020302E3172656D207267626128302C20302C20302C20302E31';
wwv_flow_api.g_varchar2_table(51) := '2920696E7365742C20302033707820397078202D327078207267626128302C20302C20302C20302E31293B0A20202F2A20466F72207665727920736D616C6C2073637265656E732C2066697420746865206D65737361676520746F2074686520746F7020';
wwv_flow_api.g_varchar2_table(52) := '6F66207468652073637265656E202A2F0A20202F2A2053657420426F726465722052616469757320746F2030206173206D657373616765206578697374732077697468696E20636F6E74656E74202A2F0A20202F2A2050616765204C6576656C20576172';
wwv_flow_api.g_varchar2_table(53) := '6E696E6720616E64204572726F7273203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F0A20202F2A2053';
wwv_flow_api.g_varchar2_table(54) := '63726F6C6C62617273202A2F0A7D0A2E666F732D416C6572742D2D70616765202E666F732D416C6572742D627574746F6E73207B0A202070616464696E672D72696768743A20303B0A7D0A2E666F732D416C6572742D2D70616765202E666F732D416C65';
wwv_flow_api.g_varchar2_table(55) := '72742D69636F6E207B0A202070616464696E672D6C6566743A20312E3672656D3B0A202070616464696E672D72696768743A203870783B0A7D0A2E752D52544C202E666F732D416C6572742D2D70616765202E666F732D416C6572742D69636F6E207B0A';
wwv_flow_api.g_varchar2_table(56) := '202070616464696E672D6C6566743A203870783B0A202070616464696E672D72696768743A20312E3672656D3B0A7D0A2E666F732D416C6572742D2D70616765202E666F732D416C6572742D69636F6E202E742D49636F6E207B0A2020666F6E742D7369';
wwv_flow_api.g_varchar2_table(57) := '7A653A20323470783B0A202077696474683A20323470783B0A20206865696768743A20323470783B0A20206C696E652D6865696768743A20313B0A7D0A2E666F732D416C6572742D2D70616765202E666F732D416C6572742D626F6479207B0A20207061';
wwv_flow_api.g_varchar2_table(58) := '6464696E672D626F74746F6D3A203870783B0A7D0A2E666F732D416C6572742D2D70616765202E666F732D416C6572742D636F6E74656E74207B0A202070616464696E673A203870783B0A7D0A2E666F732D416C6572742D2D70616765202E742D427574';
wwv_flow_api.g_varchar2_table(59) := '746F6E2D2D636C6F7365416C657274207B0A2020706F736974696F6E3A206162736F6C7574653B0A202072696768743A202D3870783B0A2020746F703A202D3870783B0A202070616464696E673A203470783B0A20206D696E2D77696474683A20303B0A';
wwv_flow_api.g_varchar2_table(60) := '20206261636B67726F756E642D636F6C6F723A20233030302021696D706F7274616E743B0A2020636F6C6F723A20234646462021696D706F7274616E743B0A2020626F782D736861646F773A203020302030203170782072676261283235352C20323535';
wwv_flow_api.g_varchar2_table(61) := '2C203235352C20302E3235292021696D706F7274616E743B0A2020626F726465722D7261646975733A20323470783B0A20207472616E736974696F6E3A202D7765626B69742D7472616E73666F726D20302E3132357320656173653B0A20207472616E73';
wwv_flow_api.g_varchar2_table(62) := '6974696F6E3A207472616E73666F726D20302E3132357320656173653B0A20207472616E736974696F6E3A207472616E73666F726D20302E3132357320656173652C202D7765626B69742D7472616E73666F726D20302E3132357320656173653B0A7D0A';
wwv_flow_api.g_varchar2_table(63) := '2E752D52544C202E666F732D416C6572742D2D70616765202E742D427574746F6E2D2D636C6F7365416C657274207B0A202072696768743A206175746F3B0A20206C6566743A202D3870783B0A7D0A2E666F732D416C6572742D2D70616765202E742D42';
wwv_flow_api.g_varchar2_table(64) := '7574746F6E2D2D636C6F7365416C6572743A686F766572207B0A20202D7765626B69742D7472616E73666F726D3A207363616C6528312E3135293B0A20207472616E73666F726D3A207363616C6528312E3135293B0A7D0A2E666F732D416C6572742D2D';
wwv_flow_api.g_varchar2_table(65) := '70616765202E742D427574746F6E2D2D636C6F7365416C6572743A616374697665207B0A20202D7765626B69742D7472616E73666F726D3A207363616C6528302E3835293B0A20207472616E73666F726D3A207363616C6528302E3835293B0A7D0A2F2A';
wwv_flow_api.g_varchar2_table(66) := '2E752D52544C202E666F732D416C6572742D2D70616765207B2072696768743A206175746F3B206C6566743A20312E3672656D3B207D2A2F0A2E666F732D416C6572742D2D706167652E666F732D416C657274207B0A2020626F726465722D7261646975';
wwv_flow_api.g_varchar2_table(67) := '733A20302E3472656D3B0A7D0A2E666F732D416C6572742D2D70616765202E666F732D416C6572742D7469746C65207B0A202070616464696E673A2038707820303B0A7D0A2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D776172';
wwv_flow_api.g_varchar2_table(68) := '6E696E67202E612D4E6F74696669636174696F6E207B0A20206D617267696E2D72696768743A203870783B0A7D0A2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E67202E612D4E6F74696669636174696F6E2D7469';
wwv_flow_api.g_varchar2_table(69) := '746C65207B0A2020666F6E742D73697A653A20312E3472656D3B0A20206C696E652D6865696768743A203272656D3B0A2020666F6E742D7765696768743A203730303B0A20206D617267696E3A20303B0A7D0A2E666F732D416C6572742D2D706167652E';
wwv_flow_api.g_varchar2_table(70) := '666F732D416C6572742D2D7761726E696E67202E612D4E6F74696669636174696F6E2D6C697374207B0A20206D61782D6865696768743A2031323870783B0A7D0A2E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6C69';
wwv_flow_api.g_varchar2_table(71) := '7374207B0A20206D61782D6865696768743A20393670783B0A20206F766572666C6F773A206175746F3B0A7D0A2E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6C696E6B3A686F766572207B0A2020746578742D6465';
wwv_flow_api.g_varchar2_table(72) := '636F726174696F6E3A20756E6465726C696E653B0A7D0A2E666F732D416C6572742D2D70616765203A3A2D7765626B69742D7363726F6C6C626172207B0A202077696474683A203870783B0A20206865696768743A203870783B0A7D0A2E666F732D416C';
wwv_flow_api.g_varchar2_table(73) := '6572742D2D70616765203A3A2D7765626B69742D7363726F6C6C6261722D7468756D62207B0A20206261636B67726F756E642D636F6C6F723A207267626128302C20302C20302C20302E3235293B0A7D0A2E666F732D416C6572742D2D70616765203A3A';
wwv_flow_api.g_varchar2_table(74) := '2D7765626B69742D7363726F6C6C6261722D747261636B207B0A20206261636B67726F756E642D636F6C6F723A207267626128302C20302C20302C20302E3035293B0A7D0A2E666F732D416C6572742D2D70616765202E666F732D416C6572742D746974';
wwv_flow_api.g_varchar2_table(75) := '6C65207B0A2020646973706C61793A20626C6F636B3B0A2020666F6E742D7765696768743A203730303B0A2020666F6E742D73697A653A20312E3872656D3B0A20206D617267696E2D626F74746F6D3A20303B0A20206D617267696E2D72696768743A20';
wwv_flow_api.g_varchar2_table(76) := '313670783B0A7D0A2E666F732D416C6572742D2D70616765202E666F732D416C6572742D626F6479207B0A20206D617267696E2D72696768743A20313670783B0A7D0A2E752D52544C202E666F732D416C6572742D2D70616765202E666F732D416C6572';
wwv_flow_api.g_varchar2_table(77) := '742D7469746C65207B0A20206D617267696E2D72696768743A20303B0A20206D617267696E2D6C6566743A20313670783B0A7D0A2E752D52544C202E666F732D416C6572742D2D70616765202E666F732D416C6572742D626F6479207B0A20206D617267';
wwv_flow_api.g_varchar2_table(78) := '696E2D72696768743A20303B0A20206D617267696E2D6C6566743A20313670783B0A7D0A2E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6C697374207B0A20206D617267696E3A203470782030203020303B0A202070';
wwv_flow_api.g_varchar2_table(79) := '616464696E673A20303B0A20206C6973742D7374796C653A206E6F6E653B0A7D0A2E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6974656D207B0A202070616464696E672D6C6566743A20323070783B0A2020706F73';
wwv_flow_api.g_varchar2_table(80) := '6974696F6E3A2072656C61746976653B0A2020666F6E742D73697A653A20313470783B0A20206C696E652D6865696768743A20323070783B0A20206D617267696E2D626F74746F6D3A203470783B0A20202F2A20457874726120536D616C6C2053637265';
wwv_flow_api.g_varchar2_table(81) := '656E73202A2F0A7D0A2E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6974656D3A6C6173742D6368696C64207B0A20206D617267696E2D626F74746F6D3A20303B0A7D0A2E752D52544C202E666F732D416C6572742D';
wwv_flow_api.g_varchar2_table(82) := '2D70616765202E612D4E6F74696669636174696F6E2D6974656D207B0A202070616464696E672D6C6566743A20303B0A202070616464696E672D72696768743A20323070783B0A7D0A2E666F732D416C6572742D2D70616765202E612D4E6F7469666963';
wwv_flow_api.g_varchar2_table(83) := '6174696F6E2D6974656D3A6265666F7265207B0A2020636F6E74656E743A2027273B0A2020706F736974696F6E3A206162736F6C7574653B0A20206D617267696E3A203870783B0A2020746F703A20303B0A20206C6566743A20303B0A20207769647468';
wwv_flow_api.g_varchar2_table(84) := '3A203470783B0A20206865696768743A203470783B0A2020626F726465722D7261646975733A20313030253B0A20206261636B67726F756E642D636F6C6F723A207267626128302C20302C20302C20302E35293B0A7D0A2F2A2E752D52544C202E666F73';
wwv_flow_api.g_varchar2_table(85) := '2D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6974656D3A6265666F7265207B2072696768743A20303B206C6566743A206175746F3B207D2A2F0A2E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F';
wwv_flow_api.g_varchar2_table(86) := '6E2D6974656D202E612D427574746F6E2D2D6E6F74696669636174696F6E207B0A202070616464696E673A203270783B0A20206F7061636974793A20302E37353B0A2020766572746963616C2D616C69676E3A20746F703B0A7D0A2E666F732D416C6572';
wwv_flow_api.g_varchar2_table(87) := '742D2D70616765202E68746D6C64624F7261457272207B0A20206D617267696E2D746F703A20302E3872656D3B0A2020646973706C61793A20626C6F636B3B0A2020666F6E742D73697A653A20312E3172656D3B0A20206C696E652D6865696768743A20';
wwv_flow_api.g_varchar2_table(88) := '312E3672656D3B0A2020666F6E742D66616D696C793A20274D656E6C6F272C2027436F6E736F6C6173272C206D6F6E6F73706163652C2073657269663B0A202077686974652D73706163653A207072652D6C696E653B0A7D0A2F2A204163636573736962';
wwv_flow_api.g_varchar2_table(89) := '6C652048656164696E67203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F0A2E666F732D416C6572742D';
wwv_flow_api.g_varchar2_table(90) := '2D61636365737369626C6548656164696E67202E666F732D416C6572742D7469746C65207B0A2020626F726465723A20303B0A2020636C69703A20726563742830203020302030293B0A20206865696768743A203170783B0A20206D617267696E3A202D';
wwv_flow_api.g_varchar2_table(91) := '3170783B0A20206F766572666C6F773A2068696464656E3B0A202070616464696E673A20303B0A2020706F736974696F6E3A206162736F6C7574653B0A202077696474683A203170783B0A7D0A2F2A2048696464656E2048656164696E6720284E6F7420';
wwv_flow_api.g_varchar2_table(92) := '41636365737369626C6529203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F0A2E666F732D416C657274';
wwv_flow_api.g_varchar2_table(93) := '2D2D72656D6F766548656164696E67202E666F732D416C6572742D7469746C65207B0A2020646973706C61793A206E6F6E653B0A7D0A406D6564696120286D61782D77696474683A20343830707829207B0A20202E666F732D416C6572742D2D70616765';
wwv_flow_api.g_varchar2_table(94) := '207B0A202020202F2A6C6566743A20312E3672656D3B2A2F0A202020206D696E2D77696474683A20303B0A202020206D61782D77696474683A206E6F6E653B0A20207D0A20202E666F732D416C6572742D2D70616765202E612D4E6F7469666963617469';
wwv_flow_api.g_varchar2_table(95) := '6F6E2D6974656D207B0A20202020666F6E742D73697A653A20313270783B0A20207D0A7D0A406D6564696120286D61782D77696474683A20373638707829207B0A20202E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C657274';
wwv_flow_api.g_varchar2_table(96) := '2D7469746C65207B0A20202020666F6E742D73697A653A20312E3872656D3B0A20207D0A7D0A2F2A202D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D';
wwv_flow_api.g_varchar2_table(97) := '2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D202A2F0A2F2A2049636F6E2E637373202A2F0A2E666F732D416C657274202E742D49636F6E2E69636F6E2D636C6F73653A6265666F7265207B0A2020666F6E742D66616D696C793A202261';
wwv_flow_api.g_varchar2_table(98) := '7065782D352D69636F6E2D666F6E74223B0A2020646973706C61793A20696E6C696E652D626C6F636B3B0A2020766572746963616C2D616C69676E3A20746F703B0A7D0A2E666F732D416C657274202E742D49636F6E2E69636F6E2D636C6F73653A6265';
wwv_flow_api.g_varchar2_table(99) := '666F7265207B0A20206C696E652D6865696768743A20313670783B0A2020666F6E742D73697A653A20313670783B0A2020636F6E74656E743A20225C65306132223B0A7D0A2F2A202D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D';
wwv_flow_api.g_varchar2_table(100) := '2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D202A2F0A2E666F7374722D746F702D63656E746572207B0A2020746F703A20312E3672656D3B0A2020726967';
wwv_flow_api.g_varchar2_table(101) := '68743A20303B0A202077696474683A20313030253B0A7D0A2E666F7374722D626F74746F6D2D63656E746572207B0A2020626F74746F6D3A20312E3672656D3B0A202072696768743A20303B0A202077696474683A20313030253B0A7D0A2E666F737472';
wwv_flow_api.g_varchar2_table(102) := '2D746F702D7269676874207B0A2020746F703A20312E3672656D3B0A202072696768743A20312E3672656D3B0A7D0A2E666F7374722D746F702D6C656674207B0A2020746F703A20312E3672656D3B0A20206C6566743A20312E3672656D3B0A7D0A2E66';
wwv_flow_api.g_varchar2_table(103) := '6F7374722D626F74746F6D2D7269676874207B0A202072696768743A20312E3672656D3B0A2020626F74746F6D3A20312E3672656D3B0A7D0A2E666F7374722D626F74746F6D2D6C656674207B0A2020626F74746F6D3A20312E3672656D3B0A20206C65';
wwv_flow_api.g_varchar2_table(104) := '66743A20312E3672656D3B0A7D0A2E666F7374722D636F6E7461696E6572207B0A2020706F736974696F6E3A2066697865643B0A20207A2D696E6465783A203939393939393B0A2020706F696E7465722D6576656E74733A206E6F6E653B0A20202F2A6F';
wwv_flow_api.g_varchar2_table(105) := '76657272696465732A2F0A7D0A2E666F7374722D636F6E7461696E6572203E20646976207B0A2020706F696E7465722D6576656E74733A206175746F3B0A7D0A2E666F7374722D636F6E7461696E65722E666F7374722D746F702D63656E746572203E20';
wwv_flow_api.g_varchar2_table(106) := '6469762C0A2E666F7374722D636F6E7461696E65722E666F7374722D626F74746F6D2D63656E746572203E20646976207B0A20202F2A77696474683A2033303070783B2A2F0A20206D617267696E2D6C6566743A206175746F3B0A20206D617267696E2D';
wwv_flow_api.g_varchar2_table(107) := '72696768743A206175746F3B0A7D0A2E666F7374722D70726F6772657373207B0A2020706F736974696F6E3A206162736F6C7574653B0A2020626F74746F6D3A20303B0A20206865696768743A203470783B0A20206261636B67726F756E642D636F6C6F';
wwv_flow_api.g_varchar2_table(108) := '723A20626C61636B3B0A20206F7061636974793A20302E343B0A7D0A68746D6C3A6E6F74282E752D52544C29202E666F7374722D70726F6772657373207B0A20206C6566743A20303B0A2020626F726465722D626F74746F6D2D6C6566742D7261646975';
wwv_flow_api.g_varchar2_table(109) := '733A20302E3472656D3B0A7D0A68746D6C2E752D52544C202E666F7374722D70726F6772657373207B0A202072696768743A20303B0A2020626F726465722D626F74746F6D2D72696768742D7261646975733A20302E3472656D3B0A7D0A406D65646961';
wwv_flow_api.g_varchar2_table(110) := '20286D61782D77696474683A20343830707829207B0A20202E666F7374722D636F6E7461696E6572207B0A202020206C6566743A20312E3672656D3B0A2020202072696768743A20312E3672656D3B0A20207D0A7D0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(44317818562555979)
,p_plugin_id=>wwv_flow_api.id(50031193176975232)
,p_file_name=>'css/fostr.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '7B2276657273696F6E223A332C22736F7572636573223A5B22666F7374722E6A73225D2C226E616D6573223A5B2277696E646F77222C22666F737472222C22746F61737454797065222C2269636F6E436C6173736573222C2273756363657373222C2269';
wwv_flow_api.g_varchar2_table(2) := '6E666F222C227761726E696E67222C226572726F72222C22636F6E7461696E657273222C2270726576696F7573546F617374222C226E6F7469667954797065222C2274797065222C226D657373616765222C227469746C65222C22756E646566696E6564';
wwv_flow_api.g_varchar2_table(3) := '222C226E6F74696679222C22636F6E736F6C65222C22636C656172416C6C222C2224222C226368696C6472656E222C2272656D6F7665222C226D6170222C22706F736974696F6E222C2224636C6F7365456C656D656E74222C226F7074696F6E73222C22';
wwv_flow_api.g_varchar2_table(4) := '657874656E64222C226469736D697373222C226469736D6973734166746572222C226E65776573744F6E546F70222C2270726576656E744475706C696361746573222C2265736361706548746D6C222C2269636F6E436C617373222C2224636F6E746169';
wwv_flow_api.g_varchar2_table(5) := '6E6572222C22616464436C617373222C22617070656E64222C22637265617465436F6E7461696E6572222C226469736D6973734F6E436C69636B222C22696E636C75646573222C226469736D6973734F6E427574746F6E222C2224746F617374456C656D';
wwv_flow_api.g_varchar2_table(6) := '656E74222C2224746F61737457726170222C222469636F6E57726170222C222469636F6E456C656D222C2224636F6E74656E74456C656D222C22247469746C65456C656D656E74222C22246D657373616765456C656D656E74222C2224627574746F6E57';
wwv_flow_api.g_varchar2_table(7) := '726170706572222C2261706578222C227574696C222C2265736361706548544D4C222C2224656C656D222C226973222C226172696156616C7565222C2270726570656E64222C2261747472222C222470726F6772657373456C656D656E74222C2274696D';
wwv_flow_api.g_varchar2_table(8) := '656F75744964222C2273657454696D656F7574222C22637373222C227769647468222C227472616E736974696F6E222C226F6E222C22636C65617254696D656F7574222C2273656C656374696F6E222C2267657453656C656374696F6E222C22616E6368';
wwv_flow_api.g_varchar2_table(9) := '6F724E6F6465222C226C656E677468222C226F6E636C69636B222C2276657273696F6E225D2C226D617070696E6773223A224141734241412C4F41414F432C4D4141512C574145582C49414149432C454143532C55414454412C4541454D2C4F41464E41';
wwv_flow_api.g_varchar2_table(10) := '2C454147532C55414854412C4541494F2C51414750432C454141632C43414364432C514141532C6B42414354432C4B41414D2C694241434E432C514141532C3042414354432C4D41414F2C6D42414750432C454141612C47414362432C45414167422C47';
wwv_flow_api.g_varchar2_table(11) := '414570422C53414153432C45414157432C4541414D432C45414153432C4741432F422C4D414175422C694241415A442C47414346432C49414344412C45414151442C45414352412C4F414155452C47414550432C4541414F2C434143564A2C4B41414D41';
wwv_flow_api.g_varchar2_table(12) := '2C4541434E432C51414153412C45414354432C4D41414F412C4B4145652C694241415A442C47414364412C45414151442C4B41414F412C45414352492C4541414F482C53414564492C51414151542C4D41414D2C7946416F4274422C53414153552C4941';
wwv_flow_api.g_varchar2_table(13) := '434C432C454141452C6F4241413242432C57414157432C5341734335432C534141534C2C4541414F4D2C4741455A2C49412F426B42432C4541714564432C4541744341432C454141554E2C454141454F2C4F41414F2C47414C6842502C454141454F2C4F';
wwv_flow_api.g_varchar2_table(14) := '41414F2C474162542C43414348432C514141532C434141432C554141572C5941437242432C614141632C4B414364432C614141612C45414362432C6D4241416D422C4541436E42432C594141592C4541435A522C534141552C59414356532C554141572C';
wwv_flow_api.g_varchar2_table(15) := '4B414358642C554141552C47414B714268422C4D41414D75422C53414B41482C4741437243572C4741684363562C4541674359452C45414151462C534176422F42642C45414157632C4941506C422C5341417942412C47414372422C49414149552C4541';
wwv_flow_api.g_varchar2_table(16) := '4161642C454141452C55414155652C534141532C53414157582C47414155572C53414E78442C6D424153482C4F414641662C454141452C5141415167422C4F41414F462C4741436A4278422C45414157632C47414159552C4541436842412C4541476F42';
wwv_flow_api.g_varchar2_table(17) := '472C4341416742622C494179423343632C45414169425A2C45414151452C51414151572C534141532C5741433143432C4541416B42642C45414151452C51414151572C534141532C594130423343452C454141674272422C454141452C2B4441504E2C43';
wwv_flow_api.g_varchar2_table(18) := '41435A642C514141572C7142414358472C4D4141532C6F42414354442C514141572C7142414358442C4B4141512C6D42414771466D422C45414151622C4D4141512C79424143374736422C4541416174422C454141452C674341436675422C4541415976';
wwv_flow_api.g_varchar2_table(19) := '422C454141452C734341436477422C4541415978422C454141452C3242414136424D2C454141514F2C5741416135422C4541415971422C45414151622C4F4141532C614143374667432C454141657A422C454141452C794341436A4230422C4541416742';
wwv_flow_api.g_varchar2_table(20) := '31422C454141452C714341436C4232422C4541416B4233422C454141452C73434143704234422C454141694235422C454141452C794341476E426F422C49414341662C45414167424C2C454141452C304B4147744271422C454141634C2C4F41414F4D2C';
wwv_flow_api.g_varchar2_table(21) := '4741437242412C454141574E2C4F41414F4F2C4741436C42412C45414155502C4F41414F512C4741436A42462C454141574E2C4F41414F532C4741436C42412C45414161542C4F41414F552C4741437042442C45414161542C4F41414F572C4741437042';
wwv_flow_api.g_varchar2_table(22) := '4C2C454141574E2C4F41414F592C47414564522C47414341512C454141655A2C4F41414F582C47414931422C49414149562C45414151572C45414151582C4D41436842412C49414349572C454141514D2C614143526A422C454141516B432C4B41414B43';
wwv_flow_api.g_varchar2_table(23) := '2C4B41414B432C5741415770432C4941456A432B422C45414163562C4F41414F72422C4941497A422C49414149442C45414155592C454141515A2C51415374422C47415249412C49414349592C454141514D2C614143526C422C454141556D432C4B4141';
wwv_flow_api.g_varchar2_table(24) := '4B432C4B41414B432C5741415772432C4941456E4369432C4541416742582C4F41414F74422C4D41497642592C454141514B2C6D424141714270422C4741416942412C4541416379432C4F4141537A432C4541416379432C4D41414D432C474141472C61';
wwv_flow_api.g_varchar2_table(25) := '4143784631432C45414163492C4F414153412C474141534A2C45414163472C53414157412C4741446A452C43417742412C4941414977432C4541434A2C4F416E424133432C45414167422C4341435A79432C4D41414F582C4541435031422C4D41414F41';
wwv_flow_api.g_varchar2_table(26) := '2C45414350442C51414153412C47414954592C45414151502C55414352412C494147414F2C45414151492C59414352492C4541415771422C51414151642C4741456E42502C45414157452C4F41414F4B2C47414B64662C45414151622C4D41435A2C4941';
wwv_flow_api.g_varchar2_table(27) := '414B2C5541434C2C4941414B2C4F41434479432C454141592C5341435A2C4D41434A2C51414349412C454141592C5941457042622C45414163652C4B41414B2C59414161462C47414768432C49414149472C4541416D4272432C454141452C5541437A42';
wwv_flow_api.g_varchar2_table(28) := '2C474141494D2C45414151472C614141652C454141472C434143314234422C454141694274422C534141532C6B42414331424D2C454141634C2C4F41414F71422C47414572422C49414149432C45414159432C594141572C57414376426C422C45414163';
wwv_flow_api.g_varchar2_table(29) := '6E422C57414366492C45414151472C6341475834422C4541416942472C494141492C4341436A42432C4D4141532C4F414354432C574141632C5541416170432C45414151472C61414A562C4B414969442C494141512C614145744638422C594141572C57';
wwv_flow_api.g_varchar2_table(30) := '414350462C4541416942472C494141492C514141532C4F41504C2C4B415737426E422C4541416373422C474141472C6D4241416D422C5741436843432C614141614E2C47414362442C45414169426E432C594167437A422C4F4133424967422C47414341';
wwv_flow_api.g_varchar2_table(31) := '472C4541416373422C474141472C534141532C57414574422C49414149452C454141592F442C4F41414F67452C6541436E42442C4741436B422C5341416C42412C4541415570442C4D4143566F442C45414155452C594143562F432C4541414536432C45';
wwv_flow_api.g_varchar2_table(32) := '414155452C5741415931422C4741416532422C4F4141532C474149704433422C454141636E422C5941496C426B422C47414341662C4541416373432C474141472C534141532C574143744274422C454141636E422C59414B532C6D4241417042492C4541';
wwv_flow_api.g_varchar2_table(33) := '415132432C5541436635422C4541416373422C474141472C5141415372432C4541415132432C534143394237422C4741416942662C4541416373432C474141472C5141415372432C4541415132432C554147704435422C474147582C4D41414F2C434143';
wwv_flow_api.g_varchar2_table(34) := '486E432C51416A4F4A2C5341416942512C45414153432C4741437442482C45414157522C4541416D42552C45414153432C4941694F7643522C4B41314E4A2C534141634F2C45414153432C4741436E42482C45414157522C4541416742552C4541415343';
wwv_flow_api.g_varchar2_table(35) := '2C4941304E7043502C51412F4E4A2C53414169424D2C45414153432C4741437442482C45414157522C4541416D42552C45414153432C49412B4E76434E2C4D41784E4A2C534141654B2C45414153432C4741437042482C45414157522C4541416942552C';
wwv_flow_api.g_varchar2_table(36) := '45414153432C4941774E7243492C53414155412C454143566D442C514141532C5541355146222C2266696C65223A22666F7374722E6A73227D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(45236093460819338)
,p_plugin_id=>wwv_flow_api.id(50031193176975232)
,p_file_name=>'js/fostr.js.map'
,p_mime_type=>'application/json'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A20676C6F62616C732061706578202A2F0A0A76617220464F53203D2077696E646F772E464F53207C7C207B7D3B0A464F532E696E74657261637469766547726964203D20464F532E696E74657261637469766547726964207C7C207B7D3B0A0A2F2A';
wwv_flow_api.g_varchar2_table(2) := '2A0A202A20546869732066756E6374696F6E2074726967676572732074686520504C2F53514C2070726F63657373696E67206F662073656C65637465642F66696C746572656420726F7773206F6E20746865207365727665722E0A202A0A202A20407061';
wwv_flow_api.g_varchar2_table(3) := '72616D207B6F626A6563747D2020206461436F6E746578742020202020202020202020202020202020202020202044796E616D696320416374696F6E20636F6E746578742061732070617373656420696E20627920415045580A202A2040706172616D20';
wwv_flow_api.g_varchar2_table(4) := '7B6F626A6563747D202020636F6E66696720202020202020202020202020202020202020202020202020436F6E66696775726174696F6E206F626A65637420686F6C64696E67207468652070726F636573732073657474696E67730A202A204070617261';
wwv_flow_api.g_varchar2_table(5) := '6D207B737472696E677D202020636F6E6669672E616A61784964202020202020202020202020202020202020414A4158206964656E7469666965722070726F76696465642062792074686520706C75672D696E20696E746572666163650A202A20407061';
wwv_flow_api.g_varchar2_table(6) := '72616D207B737472696E677D202020636F6E6669672E6D6F6465202020202020202020202020202020202020202050726F63657373696E67206D6F64652E20456974686572202773656C656374696F6E27206F72202766696C7465726564270A202A2040';
wwv_flow_api.g_varchar2_table(7) := '706172616D207B737472696E675B5D7D205B636F6E6669672E6974656D73546F5375626D69745D2020202020202020204172726179206F66206974656D206E616D657320746F207375626D697420746F20746865207365727665720A202A204070617261';
wwv_flow_api.g_varchar2_table(8) := '6D207B626F6F6C65616E7D20205B636F6E6669672E7265667265736853656C656374696F6E5D2020202020205768657468657220746F2072656672657368207468652073656C656374696F6E2061667465722070726F63657373696E670A202A20407061';
wwv_flow_api.g_varchar2_table(9) := '72616D207B626F6F6C65616E7D20205B636F6E6669672E72656672657368477269645D20202020202020202020205768657468657220746F20726566726573682074686520656E7469726520677269642061667465722070726F63657373696E670A202A';
wwv_flow_api.g_varchar2_table(10) := '2040706172616D207B626F6F6C65616E7D20205B636F6E6669672E706572666F726D537562737469747574696F6E735D202057686574686572207468652073756363657373206F72206572726F72206D6573736167652073686F756C6420706572666F72';
wwv_flow_api.g_varchar2_table(11) := '6D206974656D2073757362737469747574696F6E73206265666F7265206265696E672073686F776E0A202A2040706172616D207B626F6F6C65616E7D20205B636F6E6669672E6573636170654D6573736167655D20202020202020202057686574686572';
wwv_flow_api.g_varchar2_table(12) := '20746F20657363617065207468652073756363657373206F72206572726F72206D657373616765206265666F7265206265696E672073686F776E0A202A2040706172616D207B66756E6374696F6E7D205B696E6974466E5D202020202020202020202020';
wwv_flow_api.g_varchar2_table(13) := '20202020202020202020204A61766173637269707420696E697469616C697A6174696F6E2066756E6374696F6E20776869636820616C6C6F777320796F7520746F206F7665727269646520616E792073657474696E6773207269676874206265666F7265';
wwv_flow_api.g_varchar2_table(14) := '207468652064796E616D696320616374696F6E20697320696E766F6B656E0A202A2F0A464F532E696E746572616374697665477269642E70726F63657373526F7773203D2066756E6374696F6E20286461436F6E746578742C20636F6E6669672C20696E';
wwv_flow_api.g_varchar2_table(15) := '6974466E29207B0A0A2020202076617220706C7567696E4E616D65203D2027464F53202D20496E7465726163746976652047726964202D2050726F6365737320526F7773273B0A2020202076617220666F7374724F7074696F6E73203D207B7D3B0A2020';
wwv_flow_api.g_varchar2_table(16) := '2020617065782E64656275672E696E666F28706C7567696E4E616D652C20636F6E666967293B0A0A20202020666F7374724F7074696F6E73203D207B0A20202020202020206469736D6973733A205B276F6E436C69636B272C20276F6E427574746F6E27';
wwv_flow_api.g_varchar2_table(17) := '5D2C0A20202020202020206469736D69737341667465723A206E756C6C2C0A20202020202020206E65776573744F6E546F703A20747275652C0A202020202020202070726576656E744475706C6963617465733A20747275652C0A202020202020202065';
wwv_flow_api.g_varchar2_table(18) := '736361706548746D6C3A2066616C73652C0A2020202020202020706F736974696F6E3A2027746F702D7269676874272C0A202020202020202069636F6E436C6173733A206E756C6C2C0A2020202020202020636C656172416C6C3A2066616C73650A2020';
wwv_flow_api.g_varchar2_table(19) := '20207D3B0A0A202020202F2F20416C6C6F772074686520646576656C6F70657220746F20706572666F726D20616E79206C617374202863656E7472616C697A656429206368616E676573207573696E67204A61766173637269707420496E697469616C69';
wwv_flow_api.g_varchar2_table(20) := '7A6174696F6E20436F64650A2020202069662028696E6974466E20696E7374616E63656F662046756E6374696F6E29207B0A2020202020202020666F737472203D20666F737472207C7C207B7D3B0A2020202020202020696E6974466E2E63616C6C2864';
wwv_flow_api.g_varchar2_table(21) := '61436F6E746578742C20636F6E6669672C20666F7374724F7074696F6E73293B0A202020207D0A0A2020202076617220726567696F6E4964203D206461436F6E746578742E616374696F6E2E6166666563746564526567696F6E49643B0A202020207661';
wwv_flow_api.g_varchar2_table(22) := '7220616A61784964203D20636F6E6669672E616A617849643B0A0A2020202076617220726567696F6E203D20617065782E726567696F6E28726567696F6E4964293B0A0A202020202F2F207761726E20616E642061626F72742069662074686520616666';
wwv_flow_api.g_varchar2_table(23) := '656374656420656C656D656E74206973206E6F7420616E20496E746572616374697665204772696420726567696F6E0A202020206966202821726567696F6E207C7C20726567696F6E2E7479706520213D2027496E746572616374697665477269642729';
wwv_flow_api.g_varchar2_table(24) := '207B0A20202020202020207468726F77206E6577204572726F72282754686520616666656374656420656C656D656E74206F6620706C75672D696E202227202B20706C7567696E4E616D65202B202722206D75737420626520616E20496E746572616374';
wwv_flow_api.g_varchar2_table(25) := '697665204772696420726567696F6E2E27293B0A202020207D0A0A20202020766172206630313B0A20202020766172206F726967696E616C53656C656374696F6E3B0A0A202020202F2F20696E2073656C656374696F6E206D6F64652C2074616B652061';
wwv_flow_api.g_varchar2_table(26) := '6C6C207468652073656C656374696F6E206173206A736F6E2C20737472696E676966792069742C20616E64206368756E6B20697420696E746F206630310A2020202069662028636F6E6669672E6D6F6465203D3D202773656C656374696F6E2729207B0A';
wwv_flow_api.g_varchar2_table(27) := '20202020202020207661722073656C65637465645265636F726473203D20726567696F6E2E63616C6C282767657453656C65637465645265636F72647327293B0A0A20202020202020202F2F206B65657020747261636B206F662073656C656374696F6E';
wwv_flow_api.g_varchar2_table(28) := '20746F2072656672657368206C617465720A202020202020202069662028636F6E6669672E7265667265736853656C656374696F6E29207B0A2020202020202020202020206F726967696E616C53656C656374696F6E203D2073656C6563746564526563';
wwv_flow_api.g_varchar2_table(29) := '6F7264733B0A20202020202020207D0A0A20202020202020202F2F206966206E6F20726F7773206172652073656C65637465642C2074686572652773206E6F206E65656420746F20636F6E7461637420746865207365727665720A202020202020202069';
wwv_flow_api.g_varchar2_table(30) := '66202873656C65637465645265636F7264732E6C656E677468203D3D203029207B0A202020202020202020202020617065782E64656275672E696E666F28274E6F2073656C6563746564207265636F7264732E20436F6E74696E75696E6720776974686F';
wwv_flow_api.g_varchar2_table(31) := '7574207365727665722063616C6C2E27293B0A0A202020202020202020202020766172206572726F724F63637572726564203D2066616C73653B0A202020202020202020202020617065782E64612E726573756D65286461436F6E746578742E72657375';
wwv_flow_api.g_varchar2_table(32) := '6D6543616C6C6261636B2C206572726F724F63637572726564293B0A20202020202020202020202072657475726E3B0A20202020202020207D0A0A20202020202020202F2F2067657420616E206172726179206F6620616C6C2073656C65637465642070';
wwv_flow_api.g_varchar2_table(33) := '72696D617279206B6579732C20616E642073656E642069742061732061207374696E676966696564206A736F6E20766961206630310A2020202020202020766172206D6F64656C203D20726567696F6E2E63616C6C28276765745669657773272C202767';
wwv_flow_api.g_varchar2_table(34) := '72696427292E6D6F64656C3B0A20202020202020207661722073656C656374696F6E203D207B0A2020202020202020202020207265636F72644B6579733A2073656C65637465645265636F7264732E6D61702866756E6374696F6E20287265636F726429';
wwv_flow_api.g_varchar2_table(35) := '207B0A2020202020202020202020202020202072657475726E206D6F64656C2E5F6765745072696D6172794B6579287265636F7264293B0A2020202020202020202020207D290A20202020202020207D3B0A0A2020202020202020663031203D20617065';
wwv_flow_api.g_varchar2_table(36) := '782E7365727665722E6368756E6B284A534F4E2E737472696E676966792873656C656374696F6E29293B0A202020207D0A0A2020202076617220726573756C74203D20617065782E7365727665722E706C7567696E28616A617849642C207B0A20202020';
wwv_flow_api.g_varchar2_table(37) := '202020206630313A206630312C0A2020202020202020706167654974656D733A20636F6E6669672E6974656D73546F5375626D69740A202020207D293B0A0A20202020726573756C742E646F6E652866756E6374696F6E20286461746129207B0A202020';
wwv_flow_api.g_varchar2_table(38) := '20202020207661722063616E63656C416374696F6E73203D2066616C73653B0A0A2020202020202020766172206D657373616765203D20646174612E6D6573736167653B0A2020202020202020766172206D6573736167655469746C65203D2064617461';
wwv_flow_api.g_varchar2_table(39) := '2E6D6573736167655469746C653B0A2020202020202020766172206D65737361676554797065203D2028646174612E6D65737361676554797065202626205B27696E666F272C20277761726E696E67272C202773756363657373272C20276572726F7227';
wwv_flow_api.g_varchar2_table(40) := '2C202764616E676572275D2E696E636C7564657328646174612E6D657373616765547970652929203F20646174612E6D65737361676554797065203A202773756363657373273B0A20202020202020206D65737361676554797065203D20286D65737361';
wwv_flow_api.g_varchar2_table(41) := '676554797065203D3D3D202764616E6765722729203F20276572726F7227203A206D657373616765547970653B0A0A20202020202020202F2F20636865636B2069662074686520646576656C6F7065722077616E747320746F2063616E63656C20666F6C';
wwv_flow_api.g_varchar2_table(42) := '6C6F77696E6720616374696F6E730A202020202020202063616E63656C416374696F6E73203D202121646174612E63616E63656C416374696F6E733B202F2F20656E737572652077652068617665206120626F6F6C65616E20726573706F6E7365206966';
wwv_flow_api.g_varchar2_table(43) := '2061747472696275746520697320756E646566696E65640A0A20202020202020202F2F20706572666F726D696E6720636C69656E742D73696465206974656D2073757362737469747574696F6E730A2020202020202020696620286D6573736167655469';
wwv_flow_api.g_varchar2_table(44) := '746C6520262620636F6E6669672E706572666F726D537562737469747574696F6E7329207B0A2020202020202020202020206D6573736167655469746C65203D20617065782E7574696C2E6170706C7954656D706C617465286D6573736167655469746C';
wwv_flow_api.g_varchar2_table(45) := '652C207B0A2020202020202020202020202020202064656661756C7445736361706546696C7465723A206E756C6C0A2020202020202020202020207D293B0A20202020202020207D0A2020202020202020696620286D65737361676520262620636F6E66';
wwv_flow_api.g_varchar2_table(46) := '69672E706572666F726D537562737469747574696F6E7329207B0A2020202020202020202020206D657373616765203D20617065782E7574696C2E6170706C7954656D706C617465286D6573736167652C207B0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(47) := '64656661756C7445736361706546696C7465723A206E756C6C0A2020202020202020202020207D293B0A20202020202020207D0A0A20202020202020202F2F20706572666F726D696E67206573636170696E670A2020202020202020696620286D657373';
wwv_flow_api.g_varchar2_table(48) := '6167655469746C6520262620636F6E6669672E6573636170654D65737361676529207B0A2020202020202020202020206D6573736167655469746C65203D20617065782E7574696C2E65736361706548544D4C286D6573736167655469746C65293B0A20';
wwv_flow_api.g_varchar2_table(49) := '202020202020207D0A2020202020202020696620286D65737361676520262620636F6E6669672E6573636170654D65737361676529207B0A2020202020202020202020206D657373616765203D20617065782E7574696C2E65736361706548544D4C286D';
wwv_flow_api.g_varchar2_table(50) := '657373616765293B0A20202020202020207D0A0A202020202020202069662028646174612E737461747573203D3D2027737563636573732729207B0A0A2020202020202020202020202F2F2073657420616E79206974656D7320746F2072657475726E0A';
wwv_flow_api.g_varchar2_table(51) := '20202020202020202020202069662028646174612E6974656D73546F52657475726E29207B0A20202020202020202020202020202020666F7220287661722069203D20303B2069203C20646174612E6974656D73546F52657475726E2E6C656E6774683B';
wwv_flow_api.g_varchar2_table(52) := '20692B2B29207B0A2020202020202020202020202020202020202020617065782E6974656D28646174612E6974656D73546F52657475726E5B695D2E6E616D65292E73657456616C756528646174612E6974656D73546F52657475726E5B695D2E76616C';
wwv_flow_api.g_varchar2_table(53) := '7565293B0A202020202020202020202020202020207D0A2020202020202020202020207D0A0A2020202020202020202020202F2F20726566726573682073656C656374656420726F7773206966206F7074696F6E206973207365740A2020202020202020';
wwv_flow_api.g_varchar2_table(54) := '2020202069662028636F6E6669672E7265667265736853656C656374696F6E29207B0A20202020202020202020202020202020726567696F6E2E63616C6C28276765745669657773272C20276772696427292E6D6F64656C2E66657463685265636F7264';
wwv_flow_api.g_varchar2_table(55) := '73286F726967696E616C53656C656374696F6E293B0A2020202020202020202020207D0A0A2020202020202020202020202F2F207265667265736820656E746972652067726964206966206F7074696F6E206973207365740A2020202020202020202020';
wwv_flow_api.g_varchar2_table(56) := '2069662028636F6E6669672E726566726573684772696429207B0A20202020202020202020202020202020726567696F6E2E7265667265736828293B0A2020202020202020202020207D0A0A2020202020202020202020202F2F2073686F77206E6F7469';
wwv_flow_api.g_varchar2_table(57) := '6669636174696F6E206D6573736167650A202020202020202020202020696620286D65737361676529207B0A20202020202020202020202020202020242E657874656E6428666F7374724F7074696F6E732C207B0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(58) := '20202020206D6573736167653A20286D6573736167655469746C6529203F206D657373616765203A20756E646566696E65642C0A20202020202020202020202020202020202020207469746C653A2028216D6573736167655469746C6529203F206D6573';
wwv_flow_api.g_varchar2_table(59) := '73616765203A206D6573736167655469746C652C0A2020202020202020202020202020202020202020747970653A206D657373616765547970650A202020202020202020202020202020207D293B0A20202020202020202020202020202020666F737472';
wwv_flow_api.g_varchar2_table(60) := '5B6D657373616765547970655D28666F7374724F7074696F6E73293B0A2020202020202020202020207D0A0A20202020202020207D20656C7365207B0A20202020202020202020202063616E63656C416374696F6E73203D20747275653B0A0A20202020';
wwv_flow_api.g_varchar2_table(61) := '2020202020202020696620286D65737361676529207B0A20202020202020202020202020202020242E657874656E6428666F7374724F7074696F6E732C207B0A20202020202020202020202020202020202020206D6573736167653A20286D6573736167';
wwv_flow_api.g_varchar2_table(62) := '655469746C6529203F206D657373616765203A20756E646566696E65642C0A20202020202020202020202020202020202020207469746C653A2028216D6573736167655469746C6529203F206D657373616765203A206D6573736167655469746C652C0A';
wwv_flow_api.g_varchar2_table(63) := '2020202020202020202020202020202020202020747970653A20276572726F72270A202020202020202020202020202020207D293B0A20202020202020202020202020202020666F7374722E6572726F7228666F7374724F7074696F6E73293B0A202020';
wwv_flow_api.g_varchar2_table(64) := '2020202020202020207D0A20202020202020207D0A20202020202020200A20202020202020202F2F204F7074696F6E616C6C79206669726520616E206576656E742069662074686520646576656C6F70657220646569666E6564206F6E65207573696E67';
wwv_flow_api.g_varchar2_table(65) := '20617065785F6170706C69636174696F6E2E675F7830350A202020202020202069662028646174612E6576656E744E616D6529207B0A202020202020202020202020617065782E6576656E742E747269676765722827626F6479272C20646174612E6576';
wwv_flow_api.g_varchar2_table(66) := '656E744E616D652C2064617461293B0A20202020202020207D0A0A2020202020202020617065782E64612E726573756D65286461436F6E746578742E726573756D6543616C6C6261636B2C2063616E63656C416374696F6E73293B0A0A202020207D292E';
wwv_flow_api.g_varchar2_table(67) := '6661696C2866756E6374696F6E20286A715848522C20746578745374617475732C206572726F725468726F776E29207B0A2020202020202020617065782E64612E68616E646C65416A61784572726F7273286A715848522C20746578745374617475732C';
wwv_flow_api.g_varchar2_table(68) := '206572726F725468726F776E2C206461436F6E746578742E726573756D6543616C6C6261636B293B0A202020207D293B0A7D3B0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(50031809098975265)
,p_plugin_id=>wwv_flow_api.id(50031193176975232)
,p_file_name=>'js/script.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
prompt --application/end_environment
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done




