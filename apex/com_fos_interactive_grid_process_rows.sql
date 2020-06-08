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

prompt APPLICATION 102 - FOS Dev
--
-- Application Export:
--   Application:     102
--   Name:            FOS Dev
--   Exported By:     FOS_MASTER_WS
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 37441962356114799
--     PLUGIN: 1846579882179407086
--     PLUGIN: 8354320589762683
--     PLUGIN: 50031193176975232
--     PLUGIN: 34175298479606152
--     PLUGIN: 35822631205839510
--     PLUGIN: 14934236679644451
--     PLUGIN: 2657630155025963
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
,p_javascript_file_urls=>'#PLUGIN_FILES#js/script.min.js'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'c_plugin_name        constant varchar2(100) := ''FOS - Interactive Grid - Process Rows'';',
'c_pk_collection_name constant varchar2(100) := ''FOS_IG_PK'';',
'',
'function render',
'    ( p_dynamic_action apex_plugin.t_dynamic_action',
'    , p_plugin         apex_plugin.t_plugin',
'    )',
'return apex_plugin.t_dynamic_action_render_result',
'as',
'    l_return apex_plugin.t_dynamic_action_render_result;',
'',
'    l_affected_elem_type varchar2(100) := p_dynamic_action.affected_elements_type;',
'    l_affected_region_id varchar2(100) := p_dynamic_action.affected_region_id;',
'',
'    l_region_static_id   varchar2(100);',
'    l_region_type        varchar2(100);',
'',
'    l_is_selection_mode  boolean         := p_dynamic_action.attribute_01 = ''selection'';',
'    l_items_to_submit    apex_t_varchar2 := apex_string.split(p_dynamic_action.attribute_03, '','');',
'    l_ajax_identifier    varchar2(100)   := apex_plugin.get_ajax_identifier;',
'',
'begin',
'',
'    -- debugging',
'    apex_plugin_util.debug_dynamic_action',
'        ( p_plugin         => p_plugin',
'        , p_dynamic_action => p_dynamic_action',
'        );',
'',
'    if l_affected_region_id is null',
'    then',
'         raise_application_error(-20000, ''An Interactive Grid region must be provided as affected element for plug-in "'' || c_plugin_name || ''"'');',
'    end if;',
'',
'    -- getting the region static id and region type',
'    begin',
'        select nvl(static_id, ''R'' || l_affected_region_id)',
'             , source_type',
'          into l_region_static_id',
'             , l_region_type',
'          from apex_application_page_regions',
'         where application_id = V(''APP_ID'')',
'           and page_id        = V(''APP_PAGE_ID'')',
'           and region_id      = l_affected_region_id;',
'    exception',
'        when no_data_found',
'        then',
'            raise_application_error(-20000, ''Plug-in "'' || c_plugin_name || ''" could not find an the affected element region.'');',
'    end;',
'',
'    -- make sure the region is of type "Interactive Grid"',
'    if l_region_type != ''Interactive Grid''',
'    then',
'        raise_application_error(-20000, ''The affected element of plug-in "'' || c_plugin_name || ''" must be an Interactive Grid region.'');',
'    end if;',
'',
'    apex_json.initialize_clob_output;',
'    apex_json.open_object;',
'',
'    apex_json.write(''regionId'', l_region_static_id);',
'    apex_json.write(''ajaxId'', l_ajax_identifier);',
'    apex_json.write(''submitSelectedRecords'', l_is_selection_mode);',
'    apex_json.write(''itemsToSubmit'', l_items_to_submit);',
'',
'    apex_json.close_object;',
'',
'    l_return.javascript_function := ''function(){FOS.interactiveGrid.processRows(this, '' || apex_json.get_clob_output || '');}'';',
'',
'    apex_json.free_output;',
'',
'    return l_return;',
'end;',
'',
'procedure populate_pk_collection',
'    ( p_primary_keys_json   clob',
'    , p_primary_key_count   number',
'    )',
'as',
'    l_values        apex_json.t_values;',
'    l_elements      apex_t_varchar2;',
'    l_record_count  number;',
'',
'    l_current_pk_part   varchar2(4000);',
'    l_seq_id            number;',
'begin',
'',
'    apex_json.parse',
'        ( p_values => l_values',
'        , p_source => p_primary_keys_json',
'        );',
'',
'    apex_collection.create_or_truncate_collection(c_pk_collection_name);',
'',
'    l_record_count := apex_json.get_count',
'        ( p_values => l_values',
'        , p_path   => ''recordKeys''',
'        );',
'',
'    for i in 1 .. l_record_count',
'    loop',
'',
'        l_elements := apex_json.get_t_varchar2',
'            ( p_values  => l_values',
'            , p_path    => ''recordKeys[%d]''',
'            , p0        => i',
'            );',
'',
'        for j in 1 .. p_primary_key_count',
'        loop',
'',
'            l_current_pk_part := apex_json.get_varchar2',
'                ( p_values  => l_values',
'                , p_path    => ''recordKeys[%d][%d]''',
'                , p0        => i',
'                , p1        => j',
'                );',
'',
'            if j = 1',
'            then',
'                l_seq_id := apex_collection.add_member',
'                    ( p_collection_name => c_pk_collection_name',
'                    , p_c001            => l_current_pk_part',
'                    );',
'            else',
'                apex_collection.update_member_attribute',
'                    ( p_collection_name => c_pk_collection_name',
'                    , p_seq             => l_seq_id',
'                    , p_attr_number     => j',
'                    , p_attr_value      => l_current_pk_part',
'                    );',
'            end if;',
'        end loop;',
'    end loop;',
'end;',
'',
'function ajax',
'    ( p_dynamic_action apex_plugin.t_dynamic_action',
'    , p_plugin         apex_plugin.t_plugin',
'    )',
'return apex_plugin.t_dynamic_action_ajax_result',
'as',
'',
'    c_bug_workaround_name   constant varchar2(4000) := ''FOS_APEX_192_BUG_30665079_WORKAROUND'';',
'',
'    l_affected_elem_type    constant varchar2(4000) := p_dynamic_action.affected_elements_type;',
'    l_affected_region_id    constant varchar2(4000) := p_dynamic_action.affected_region_id;',
'',
'    l_is_selection_mode constant boolean := p_dynamic_action.attribute_01 = ''selection'';',
'    ',
'    c_items_to_return   constant apex_t_varchar2 := apex_string.split(p_dynamic_action.attribute_04, '','');',
'',
'    c_plsql_code        constant varchar2(4000) := p_dynamic_action.attribute_02;',
'',
'    l_region_static_id  varchar2(100);',
'    l_region_type       varchar2(100);',
'',
'    l_context           apex_exec.t_context;',
'',
'    --needed for the selection filter',
'    l_selected_records  clob := '''';',
'    l_filters           apex_exec.t_filters;',
'    l_column_count      number;',
'    l_primary_key_count number := 0;',
'    l_primary_key_cols  apex_t_varchar2 := apex_t_varchar2();',
'    l_collection_cols   apex_t_varchar2 := apex_t_varchar2();',
'    l_current_column    apex_exec.t_column;',
'    l_context_filter    varchar2(4000);',
'',
'    l_return apex_plugin.t_dynamic_action_ajax_result;',
'',
'begin',
'',
'    --debugging',
'    if apex_application.g_debug then',
'        apex_plugin_util.debug_dynamic_action',
'            ( p_plugin         => p_plugin',
'            , p_dynamic_action => p_dynamic_action',
'            );',
'    end if;',
'',
'    apex_application.g_x01 := c_bug_workaround_name;',
'',
'    if l_is_selection_mode then',
'',
'        l_context := apex_region.open_query_context',
'            ( p_page_id     => V(''APP_PAGE_ID'')',
'            , p_region_id   => l_affected_region_id',
'            );',
'',
'        --rebuilding the primary key json',
'        for idx in 1 .. apex_application.g_f01.count',
'        loop',
'            l_selected_records := l_selected_records || apex_application.g_f01(idx);',
'        end loop;',
'',
'        l_column_count := apex_exec.get_column_count(l_context);',
'',
'        for idx in 1 .. l_column_count',
'        loop',
'',
'            l_current_column := apex_exec.get_column',
'                ( p_context     => l_context',
'                , p_column_idx  => idx',
'                );',
'',
'            if l_current_column.is_primary_key',
'            then',
'                l_primary_key_count := l_primary_key_count + 1;',
'                l_primary_key_cols.extend(1);',
'                l_primary_key_cols(l_primary_key_cols.count) := l_current_column.name;',
'',
'                l_collection_cols.extend(1);',
'                l_collection_cols(l_collection_cols.count) := ''c'' || lpad(l_collection_cols.count, 3, ''0'');',
'            end if;',
'',
'        end loop;',
'',
'        if l_primary_key_cols.count = 0',
'        then',
'            raise_application_error(-20000, ''The Interactive Grid referenced by "'' || c_plugin_name || ''" must have a primary key.'');',
'        end if;',
'',
'        l_context_filter := ''(#PRIMARY_KEY_COLUMNS#) in (select #COLLECTION_COLUMNS# from apex_collections where collection_name = ''''#COLLECTION_NAME#'''')'';',
'        l_context_filter := replace(l_context_filter, ''#PRIMARY_KEY_COLUMNS#'', apex_string.join(l_primary_key_cols, '',''));',
'        l_context_filter := replace(l_context_filter, ''#COLLECTION_COLUMNS#'', apex_string.join(l_collection_cols, '',''));',
'        l_context_filter := replace(l_context_filter, ''#COLLECTION_NAME#'', c_pk_collection_name);',
'',
'        apex_exec.add_filter',
'            ( p_filters         => l_filters',
'            , p_sql_expression  => l_context_filter',
'            );',
'',
'        populate_pk_collection',
'            ( p_primary_keys_json   => l_selected_records',
'            , p_primary_key_count   => l_primary_key_cols.count',
'            );',
'',
'        apex_exec.close(l_context);',
'    end if;',
'',
'    apex_application.g_x01 := c_bug_workaround_name;',
'',
'    l_context := apex_region.open_query_context',
'        ( p_page_id             => V(''APP_PAGE_ID'')',
'        , p_region_id           => l_affected_region_id',
'        , p_additional_filters  => l_filters',
'        );',
'',
'    while apex_exec.next_row(l_context)',
'    loop',
'        apex_exec.execute_plsql(c_plsql_code);',
'    end loop;',
'',
'    apex_exec.close(l_context);',
'',
'    if l_is_selection_mode',
'    then',
'        apex_collection.delete_collection(c_pk_collection_name);',
'    end if;',
'',
'    apex_json.open_object;',
'    apex_json.write(''status'', ''success'');',
'    ',
'    if c_items_to_return.count > 0',
'    then',
'        apex_json.open_array(''itemsToReturn'');',
'        ',
'        for idx in 1 .. c_items_to_return.count',
'        loop',
'            apex_json.open_object;',
'            apex_json.write(''name'', c_items_to_return(idx));',
'            apex_json.write(''value'', V(c_items_to_return(idx)));',
'            apex_json.close_object;',
'        end loop;',
'',
'        apex_json.close_array;',
'    end if;',
'    ',
'    apex_json.close_object;',
'',
'    return l_return;',
'exception',
'    when others',
'    then',
'        apex_exec.close(l_context);',
'        raise;',
'end;'))
,p_api_version=>2
,p_render_function=>'render'
,p_ajax_function=>'ajax'
,p_standard_attributes=>'REGION:REQUIRED:STOP_EXECUTION_ON_ERROR:WAIT_FOR_RESULT'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>'<p>This plug-in executes PL/SQL code for each selected or filtered Interactive Grid row.</p>'
,p_version_identifier=>'20.1.0'
,p_about_url=>'https://fos.world'
,p_files_version=>68
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
,p_default_value=>'SELECTION'
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
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '77696E646F772E464F533D77696E646F772E464F537C7C7B7D2C464F532E696E746572616374697665477269643D464F532E696E746572616374697665477269647C7C7B7D2C464F532E696E746572616374697665477269642E70726F63657373526F77';
wwv_flow_api.g_varchar2_table(2) := '733D66756E6374696F6E28652C72297B76617220693D22464F53202D20496E7465726163746976652047726964202D2050726F6365737320526F7773223B617065782E64656275672E696E666F28692C226461222C65292C617065782E64656275672E69';
wwv_flow_api.g_varchar2_table(3) := '6E666F28692C22636F6E666967222C72293B76617220742C613D722E726567696F6E49642C6E3D722E616A617849642C6F3D617065782E726567696F6E2861293B696628216F7C7C22496E7465726163746976654772696422213D6F2E74797065297468';
wwv_flow_api.g_varchar2_table(4) := '726F77206E6577204572726F72282754686520616666656374656420656C656D656E74206F6620706C75672D696E2022272B692B2722206D75737420626520616E20496E746572616374697665204772696420726567696F6E2E27293B696628722E7375';
wwv_flow_api.g_varchar2_table(5) := '626D697453656C65637465645265636F726473297B76617220733D6F2E63616C6C282267657453656C65637465645265636F72647322293B696628303D3D732E6C656E677468297B617065782E64656275672E696E666F28224E6F2073656C6563746564';
wwv_flow_api.g_varchar2_table(6) := '207265636F7264732E20436F6E74696E75696E6720776974686F7574207365727665722063616C6C2E22293B72657475726E20766F696420617065782E64612E726573756D6528652E726573756D6543616C6C6261636B2C2131297D76617220633D6F2E';
wwv_flow_api.g_varchar2_table(7) := '63616C6C28226765745669657773222C226772696422292E6D6F64656C2C643D7B7265636F72644B6579733A732E6D6170282866756E6374696F6E2865297B72657475726E20632E5F6765745072696D6172794B65792865297D29297D3B743D61706578';
wwv_flow_api.g_varchar2_table(8) := '2E7365727665722E6368756E6B284A534F4E2E737472696E67696679286429297D617065782E7365727665722E706C7567696E286E2C7B6630313A742C706167654974656D733A722E6974656D73546F5375626D69747D292E646F6E65282866756E6374';
wwv_flow_api.g_varchar2_table(9) := '696F6E2872297B76617220693B6966282273756363657373223D3D722E737461747573297B696628693D21312C722E6974656D73546F52657475726E29666F722876617220743D303B743C722E6974656D73546F52657475726E2E6C656E6774683B742B';
wwv_flow_api.g_varchar2_table(10) := '2B29617065782E6974656D28722E6974656D73546F52657475726E5B745D2E6E616D65292E73657456616C756528722E6974656D73546F52657475726E5B745D2E76616C7565297D656C736520693D21303B617065782E64612E726573756D6528652E72';
wwv_flow_api.g_varchar2_table(11) := '6573756D6543616C6C6261636B2C69297D29292E6661696C282866756E6374696F6E28722C692C74297B617065782E64612E68616E646C65416A61784572726F727328722C692C742C652E726573756D6543616C6C6261636B297D29297D3B0A2F2F2320';
wwv_flow_api.g_varchar2_table(12) := '736F757263654D617070696E6755524C3D7363726970742E6A732E6D6170';
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
wwv_flow_api.g_varchar2_table(1) := '7B2276657273696F6E223A332C22736F7572636573223A5B227363726970742E6A73225D2C226E616D6573223A5B2277696E646F77222C22464F53222C22696E74657261637469766547726964222C2270726F63657373526F7773222C226461222C2263';
wwv_flow_api.g_varchar2_table(2) := '6F6E666967222C22706C7567696E4E616D65222C2261706578222C226465627567222C22696E666F222C22663031222C22726567696F6E4964222C22616A61784964222C22726567696F6E222C2274797065222C224572726F72222C227375626D697453';
wwv_flow_api.g_varchar2_table(3) := '656C65637465645265636F726473222C2273656C65637465645265636F726473222C2263616C6C222C226C656E677468222C22726573756D65222C22726573756D6543616C6C6261636B222C226D6F64656C222C2273656C656374696F6E222C22726563';
wwv_flow_api.g_varchar2_table(4) := '6F72644B657973222C226D6170222C227265636F7264222C225F6765745072696D6172794B6579222C22736572766572222C226368756E6B222C224A534F4E222C22737472696E67696679222C22706C7567696E222C22706167654974656D73222C2269';
wwv_flow_api.g_varchar2_table(5) := '74656D73546F5375626D6974222C22646F6E65222C2264617461222C226572726F724F63637572726564222C22737461747573222C226974656D73546F52657475726E222C2269222C226974656D222C226E616D65222C2273657456616C7565222C2276';
wwv_flow_api.g_varchar2_table(6) := '616C7565222C226661696C222C226A71584852222C2274657874537461747573222C226572726F725468726F776E222C2268616E646C65416A61784572726F7273225D2C226D617070696E6773223A2241414141412C4F41414F432C4941414D442C4F41';
wwv_flow_api.g_varchar2_table(7) := '414F432C4B41414F2C4741433342412C49414149432C674241416B42442C49414149432C694241416D422C4741453743442C49414149432C674241416742432C594141632C53414153432C45414149432C47414533432C49414149432C454141612C7743';
wwv_flow_api.g_varchar2_table(8) := '41456A42432C4B41414B432C4D41414D432C4B41414B482C454141592C4B41414D462C4741436C43472C4B41414B432C4D41414D432C4B41414B482C454141592C53414155442C47414574432C494153494B2C45415441432C454141574E2C4541414F4D';
wwv_flow_api.g_varchar2_table(9) := '2C5341436C42432C45414153502C4541414F4F2C4F41456842432C454141534E2C4B41414B4D2C4F41414F462C4741457A422C49414149452C47414179422C6D42414166412C4541414F432C4B41436A422C4D41414D2C49414149432C4D41414D2C6F43';
wwv_flow_api.g_varchar2_table(10) := '41417343542C454141612C7943414B76452C47414147442C4541414F572C7342414173422C43414335422C49414149432C4541416B424A2C4541414F4B2C4B41414B2C734241456C432C47414136422C4741413142442C4541416742452C4F4141592C43';
wwv_flow_api.g_varchar2_table(11) := '414333425A2C4B41414B432C4D41414D432C4B41414B2C7744414968422C59414441462C4B41414B482C4741414767422C4F41414F68422C4541414769422C67424144452C47414B78422C49414149432C45414151542C4541414F4B2C4B41414B2C5741';
wwv_flow_api.g_varchar2_table(12) := '41592C51414151492C4D41437843432C454141592C4341435A432C57414159502C4541416742512C4B4141492C53414153432C47414372432C4F41414F4A2C4541414D4B2C65414165442C4F4149704368422C4541414D482C4B41414B71422C4F41414F';
wwv_flow_api.g_varchar2_table(13) := '432C4D41414D432C4B41414B432C55414155522C494147394268422C4B41414B71422C4F41414F492C4F41414F70422C454141512C4341437043462C4941414B412C4541434C75422C5541415735422C4541414F36422C6742414766432C4D41414B2C53';
wwv_flow_api.g_varchar2_table(14) := '414153432C4741436A422C49414149432C4541454A2C4741416B422C57414166442C4541414B452C5141454A2C47414441442C47414167422C45414362442C4541414B472C6341434A2C494141492C49414149432C454141492C45414147412C45414145';
wwv_flow_api.g_varchar2_table(15) := '4A2C4541414B472C6341416370422C4F41415171422C49414378436A432C4B41414B6B432C4B41414B4C2C4541414B472C63414163432C47414147452C4D41414D432C53414153502C4541414B472C63414163432C47414147492C5941493745502C4741';
wwv_flow_api.g_varchar2_table(16) := '4167422C454147704239422C4B41414B482C4741414767422C4F41414F68422C4541414769422C654141674267422C4D41456E43512C4D41414B2C53414153432C4541414F432C45414159432C47414368437A432C4B41414B482C4741414736432C6942';
wwv_flow_api.g_varchar2_table(17) := '41416942482C4541414F432C45414159432C4541416135432C454141476942222C2266696C65223A227363726970742E6A73227D';
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
wwv_flow_api.g_varchar2_table(1) := '77696E646F772E464F53203D2077696E646F772E464F53207C7C207B7D3B0A464F532E696E74657261637469766547726964203D20464F532E696E74657261637469766547726964207C7C207B7D3B0A0A464F532E696E74657261637469766547726964';
wwv_flow_api.g_varchar2_table(2) := '2E70726F63657373526F7773203D2066756E6374696F6E2864612C20636F6E666967297B0A0A2020202076617220706C7567696E4E616D65203D2027464F53202D20496E7465726163746976652047726964202D2050726F6365737320526F7773273B0A';
wwv_flow_api.g_varchar2_table(3) := '0A20202020617065782E64656275672E696E666F28706C7567696E4E616D652C20276461272C206461293B0A20202020617065782E64656275672E696E666F28706C7567696E4E616D652C2027636F6E666967272C20636F6E666967293B0A0A20202020';
wwv_flow_api.g_varchar2_table(4) := '76617220726567696F6E4964203D20636F6E6669672E726567696F6E49643B0A2020202076617220616A61784964203D20636F6E6669672E616A617849643B0A0A2020202076617220726567696F6E203D20617065782E726567696F6E28726567696F6E';
wwv_flow_api.g_varchar2_table(5) := '4964293B0A0A2020202069662821726567696F6E207C7C20726567696F6E2E7479706520213D2027496E7465726163746976654772696427297B0A20202020202020207468726F77206E6577204572726F72282754686520616666656374656420656C65';
wwv_flow_api.g_varchar2_table(6) := '6D656E74206F6620706C75672D696E202227202B20706C7567696E4E616D65202B202722206D75737420626520616E20496E746572616374697665204772696420726567696F6E2E27293B0A202020207D0A0A20202020766172206630313B0A0A202020';
wwv_flow_api.g_varchar2_table(7) := '20696628636F6E6669672E7375626D697453656C65637465645265636F726473297B0A20202020202020207661722073656C65637465645265636F726473203D20726567696F6E2E63616C6C282767657453656C65637465645265636F72647327293B0A';
wwv_flow_api.g_varchar2_table(8) := '0A202020202020202069662873656C65637465645265636F7264732E6C656E677468203D3D2030297B0A202020202020202020202020617065782E64656275672E696E666F28274E6F2073656C6563746564207265636F7264732E20436F6E74696E7569';
wwv_flow_api.g_varchar2_table(9) := '6E6720776974686F7574207365727665722063616C6C2E27293B0A2020202020202020202020200A202020202020202020202020766172206572726F724F63637572726564203D2066616C73653B0A202020202020202020202020617065782E64612E72';
wwv_flow_api.g_varchar2_table(10) := '6573756D652864612E726573756D6543616C6C6261636B2C206572726F724F63637572726564293B0A20202020202020202020202072657475726E3B0A20202020202020207D0A0A2020202020202020766172206D6F64656C203D20726567696F6E2E63';
wwv_flow_api.g_varchar2_table(11) := '616C6C28276765745669657773272C20276772696427292E6D6F64656C3B0A20202020202020207661722073656C656374696F6E203D207B0A2020202020202020202020207265636F72644B6579733A2073656C65637465645265636F7264732E6D6170';
wwv_flow_api.g_varchar2_table(12) := '2866756E6374696F6E287265636F7264297B0A2020202020202020202020202020202072657475726E206D6F64656C2E5F6765745072696D6172794B6579287265636F7264293B0A2020202020202020202020207D290A20202020202020207D3B0A0A20';
wwv_flow_api.g_varchar2_table(13) := '20202020202020663031203D20617065782E7365727665722E6368756E6B284A534F4E2E737472696E676966792873656C656374696F6E29293B200A202020207D0A0A2020202076617220726573756C74203D20617065782E7365727665722E706C7567';
wwv_flow_api.g_varchar2_table(14) := '696E28616A617849642C207B0A20202020202020206630313A206630312C0A2020202020202020706167654974656D733A20636F6E6669672E6974656D73546F5375626D69740A202020207D293B0A0A20202020726573756C742E646F6E652866756E63';
wwv_flow_api.g_varchar2_table(15) := '74696F6E2864617461297B0A2020202020202020766172206572726F724F636375727265643B0A20202020202020200A2020202020202020696628646174612E737461747573203D3D20277375636365737327297B0A2020202020202020202020206572';
wwv_flow_api.g_varchar2_table(16) := '726F724F63637572726564203D2066616C73653B0A202020202020202020202020696628646174612E6974656D73546F52657475726E297B0A20202020202020202020202020202020666F72287661722069203D20303B20693C646174612E6974656D73';
wwv_flow_api.g_varchar2_table(17) := '546F52657475726E2E6C656E6774683B20692B2B297B0A2020202020202020202020202020202020202020617065782E6974656D28646174612E6974656D73546F52657475726E5B695D2E6E616D65292E73657456616C756528646174612E6974656D73';
wwv_flow_api.g_varchar2_table(18) := '546F52657475726E5B695D2E76616C7565293B0A202020202020202020202020202020207D0A2020202020202020202020207D0A20202020202020207D20656C7365207B0A2020202020202020202020206572726F724F63637572726564203D20747275';
wwv_flow_api.g_varchar2_table(19) := '653B0A20202020202020207D0A20202020202020200A2020202020202020617065782E64612E726573756D652864612E726573756D6543616C6C6261636B2C206572726F724F63637572726564293B0A0A202020207D292E6661696C2866756E6374696F';
wwv_flow_api.g_varchar2_table(20) := '6E286A715848522C20746578745374617475732C206572726F725468726F776E297B0A2020202020202020617065782E64612E68616E646C65416A61784572726F7273286A715848522C20746578745374617475732C206572726F725468726F776E2C20';
wwv_flow_api.g_varchar2_table(21) := '64612E726573756D6543616C6C6261636B293B0A202020207D293B0A7D3B0A';
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


