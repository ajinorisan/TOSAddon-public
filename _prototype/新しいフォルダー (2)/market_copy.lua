-- market.lua
--[[<?xml version="1.0" encoding="UTF-8"?>
<!-- edited with XMLSPY v2004 rel. 3 U (http://www.xmlspy.com) by imc (imc) -->
<uiframe name="market" x="0" y="0" width="1425" height="1000" create="open">
	<frame title="{@st43}{s22}마켓{/}" titlepos="0 0" layout_gravity="left center" margin="0 -20 0 0" scale_align="center top" tooltipoverlap="true"/>
	<option closebutton="false" hideable="false" escscript="ON_MARKET_ESCAPE_PRESSED"/>
	<draw drawframe="false" drawtitlebar="false" drawnotitlebar="false"/>
	<script CloseScp="MARKET_CLOSE"/>
	<sound opensound="sys_popup_open_1" closesound="character_item_window_close"/>
	<layer layerlevel="99"/>
	<userconfig RECIPE_BG_HEIGHT="765" ITEM_CTRLSET_INTERVAL_Y_MARGIN="-0.3" CATEGORY_SAVE_OPTION_SKIN="chat_window_2"/>
	<controls>
		<groupbox name="market_low" rect="0 0 1425 900" margin="0 95 0 0" layout_gravity="center top" draw="true" hittestbox="false" resizebyparent="false" skin="test_frame_low"/>
		<groupbox name="market_midle3" rect="0 0 1067 765" margin="348 153 0 0" layout_gravity="left top" draw="true" hittestbox="false" resizebyparent="false" skin="test_frame_midle_light"/>
		<groupbox name="market_material_bg" rect="0 0 1067 434" margin="348 0 0 82" layout_gravity="left bottom" draw="true" hittestbox="false" resizebyparent="false" skin="test_frame_midle_light"/>
		<groupbox name="market_title" rect="0 0 1425 99" margin="0 0 0 0" layout_gravity="center top" draw="true" hittestbox="false" resizebyparent="false" skin="market_title"/>
		<richtext name="title" rect="0 0 100 30" margin="0 33 0 0" layout_gravity="center top" caption="{@st43}{s24}마켓{/}" drawbackground="false" fixwidth="false" fontname="white_16_ol" maxwidth="0" resizebytext="true" slideshow="false" spacey="0" textalign="center center" updateparent="false"/>
		<pagecontroller name="pagecontrol" rect="0 0 1020 40" margin="165 0 0 25" layout_gravity="center bottom" image="{@st66d} {@st66d_y}" nextScp="MARKET_PAGE_SELECT_NEXT" prevScp="MARKET_PAGE_SELECT_PREV" selectScp="MARKET_PAGE_SELECT" slot="35 25" space="100 0 8 100" type="richtext" movebyone="true" showpagecnt="10">
			<prev size="60 40" margin="60 0 0 0" layout_gravity="left top" caption="{img white_left_arrow 18 18}" skin="test_normal_button"/>
			<next size="60 40" margin="0 0 60 0" layout_gravity="right top" caption="{img white_right_arrow 18 18}" skin="test_normal_button"/>
			<prevunit size="60 40" margin="0 0 0 0" layout_gravity="left top" caption="{img white_left_arrow 18 18}{img white_left_arrow 18 18}" skin="test_normal_button"/>
			<nextunit size="60 40" margin="0 0 0 0" layout_gravity="right top" caption="{img white_right_arrow 18 18}{img white_right_arrow 18 18}" skin="test_normal_button"/>
		</pagecontroller>
		<pagecontroller name="pagecontrol_recipe" rect="0 0 1020 40" margin="165 0 0 565" layout_gravity="center bottom" image="{@st66d} {@st66d_y}" nextScp="RECIPE_SEARCH_PAGE_SELECT_NEXT" prevScp="RECIPE_SEARCH_SELECT_PREV" selectScp="RECIPE_SEARCH_PAGE_SELECT" slot="35 25" space="100 0 8 100" type="richtext" movebyone="true" showpagecnt="10">
			<prev size="60 40" margin="60 0 0 0" layout_gravity="left top" caption="{img white_left_arrow 18 18}" skin="test_normal_button"/>
			<next size="60 40" margin="0 0 60 0" layout_gravity="right top" caption="{img white_right_arrow 18 18}" skin="test_normal_button"/>
			<prevunit size="60 40" margin="0 0 0 0" layout_gravity="left top" caption="{img white_left_arrow 18 18}{img white_left_arrow 18 18}" skin="test_normal_button"/>
			<nextunit size="60 40" margin="0 0 0 0" layout_gravity="right top" caption="{img white_right_arrow 18 18}{img white_right_arrow 18 18}" skin="test_normal_button"/>
		</pagecontroller>
		<pagecontroller name="pagecontrol_material" rect="0 0 1020 40" margin="165 0 0 25" layout_gravity="center bottom" image="{@st66d} {@st66d_y}" nextScp="MATERIAL_SEARCH_PAGE_SELECT_NEXT" prevScp="MATERIAL_SEARCH_SELECT_PREV" selectScp="MATERIAL_SEARCH_PAGE_SELECT" slot="35 25" space="100 0 8 100" type="richtext" movebyone="true" showpagecnt="10">
			<prev size="60 40" margin="60 0 0 0" layout_gravity="left top" caption="{img white_left_arrow 18 18}" skin="test_normal_button"/>
			<next size="60 40" margin="0 0 60 0" layout_gravity="right top" caption="{img white_right_arrow 18 18}" skin="test_normal_button"/>
			<prevunit size="60 40" margin="0 0 0 0" layout_gravity="left top" caption="{img white_left_arrow 18 18}{img white_left_arrow 18 18}" skin="test_normal_button"/>
			<nextunit size="60 40" margin="0 0 0 0" layout_gravity="right top" caption="{img white_right_arrow 18 18}{img white_right_arrow 18 18}" skin="test_normal_button"/>
		</pagecontroller>
		<button name="marketCabinet" rect="0 0 200 45" margin="410 105 0 0" layout_gravity="left top" LBtnUpScp="MARKET_CABINET_MODE" caption="{@st66b18}수령함" clicksound="button_click" oversound="button_over" param1="newitemtext" skin="tab2_btn"/>
		<button name="marketSell" rect="0 0 200 45" margin="210 105 0 0" layout_gravity="left top" LBtnUpScp="MARKET_SELLMODE" caption="{@st66b18}판매" clicksound="button_click" oversound="button_over" skin="tab2_btn"/>
		<button name="close" rect="0 0 44 44" margin="0 0 0 0" layout_gravity="right top" LBtnUpScp="ui.CloseFrame(&apos;market&apos;)" clicksound="button_click_big" image="testclose_button" oversound="button_over" texttooltip="{@st59}마켓 창을 닫습니다{/}" MouseOffAnim="btn_mouseoff" MouseOnAnim="btn_mouseover"/>
		<button name="marketBuy" rect="0 0 200 45" margin="10 105 0 0" layout_gravity="left top" caption="{@st66b18}구매" clicksound="button_click" oversound="button_over" skin="tab2_btn_2"/>
		<groupbox name="itemListGbox" rect="0 0 1167 730 " margin="348 188 0 0" scrollbar="false" hittestbox="false" skin="" layout_gravity="left top"/>
		<groupbox name="defaultTitle" rect="0 0 1067 40" margin="0 0 0 0" parent="market_midle3" scrollbar="false" hittestbox="false" skin="market_listbase" layout_gravity="left top"/>
		<groupbox name="recipeSearchGbox" rect="0 0 1167 400" margin="348 519 0 0" scrollbar="false" hittestbox="false" skin="" layout_gravity="left top"/>
		<groupbox name="equipTitle" rect="0 0 1067 40" margin="0 0 0 0" parent="market_midle3" scrollbar="false" hittestbox="false" skin="market_listbase" layout_gravity="left top"/>
		<groupbox name="recipeTitle" rect="0 0 1067 40" margin="0 0 0 0" parent="market_midle3" scrollbar="false" hittestbox="false" skin="market_listbase" layout_gravity="left top"/>
		<groupbox name="accessoryTitle" rect="0 0 1067 40" margin="0 0 0 0" parent="market_midle3" scrollbar="false" hittestbox="false" skin="market_listbase" layout_gravity="left top"/>
		<groupbox name="gemTitle" rect="0 0 1067 40" margin="0 0 0 0" parent="market_midle3" scrollbar="false" hittestbox="false" skin="market_listbase" layout_gravity="left top"/>
		<groupbox name="cardTitle" rect="0 0 1067 40" margin="0 0 0 0" parent="market_midle3" scrollbar="false" hittestbox="false" skin="market_listbase" layout_gravity="left top"/>
		<groupbox name="exporbTitle" rect="0 0 1067 40" margin="0 0 0 0" parent="market_midle3" scrollbar="false" hittestbox="false" skin="market_listbase" layout_gravity="left top"/>
		<groupbox name="OPTMiscTitle" rect="0 0 1067 40" margin="0 0 0 0" parent="market_midle3" scrollbar="false" hittestbox="false" skin="market_listbase" layout_gravity="left top"/>
		<groupbox name="recipeSearchTitle" rect="0 0 1067 40" margin="348 484 0 0" scrollbar="false" hittestbox="false" skin="market_listbase" layout_gravity="left top"/>
		<groupbox name="recipeSearchTemp" rect="0 0 1067 40" margin="348 445 0 0" scrollbar="false" hittestbox="false" skin="None" layout_gravity="left top"/>
		<richtext name="defaultTitle_name" margin="90 0 0 0" rect="0 0 120 24" caption="{@st66b}{s18}이름{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="defaultTitle"/>
		<richtext name="defaultTitle_level" margin="305 0 0 0" rect="0 0 120 24" caption="{@st66b}{s18}레벨{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="defaultTitle"/>
		<richtext name="defaultTitle_price" margin="422 0 0 0" rect="0 0 120 24" sharedConst="USE_MARKET_REPORT/0" caption="{@st66b}{s18}단가{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="defaultTitle"/>
		<richtext name="defaultTitle_price" margin="422 0 0 0" rect="0 0 120 24" sharedConst="USE_MARKET_REPORT/1" caption="{@st66b}{s18}단가{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="defaultTitle"/>
		<richtext name="defaultTitle_cnt" margin="580 0 0 0" rect="0 0 120 24" sharedConst="USE_MARKET_REPORT/0" caption="{@st66b}{s18}구매 개수{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="defaultTitle"/>
		<richtext name="defaultTitle_cnt" margin="580 0 0 0" rect="0 0 120 24" sharedConst="USE_MARKET_REPORT/1" caption="{@st66b}{s18}구매 개수{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="defaultTitle"/>
		<richtext name="defaultTitle_totalPrice" margin="755 0 0 0" rect="0 0 120 24" sharedConst="USE_MARKET_REPORT/0" caption="{@st66b}{s18}총 금액{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="defaultTitle"/>
		<richtext name="defaultTitle_totalPrice" margin="755 0 0 0" rect="0 0 120 24" sharedConst="USE_MARKET_REPORT/1" caption="{@st66b}{s18}총 금액{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="defaultTitle"/>
		<richtext name="equipTitle_transcend" margin="0 0 0 0" rect="0 0 120 24" caption="{@st66b}{s18} {/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="equipTitle"/>
		<richtext name="equipTitle_reinforce" margin="80 0 0 0" rect="0 0 120 24" caption="{@st66b}{s18} {/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="equipTitle"/>
		<richtext name="equipTitle_name" margin="90 0 0 0" rect="0 0 120 24" caption="{@st66b}{s18}이름{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="equipTitle"/>
		<richtext name="equipTitle_level" margin="300 0 0 0" rect="0 0 120 24" caption="{@st66b}{s18}레벨{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="equipTitle"/>
		<richtext name="equipTitle_stats" margin="420 0 0 0" rect="0 0 120 24" caption="{@st66b}{s18}능력치{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="equipTitle"/>
		<richtext name="equipTitle_socket" margin="608 0 0 0" rect="0 0 120 24" caption="{@st66b}{s18}소켓{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="equipTitle"/>
		<richtext name="equipTitle_potential" margin="690 0 0 0" rect="0 0 120 24" caption="{@st66b}{s18}포텐셜{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="equipTitle"/>
		<richtext name="equipTitle_price" margin="815 0 0 0" rect="0 0 120 24" caption="{@st66b}{s18}금액{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="equipTitle"/>
		<richtext name="recipeTitle_name" margin="90 0 0 0" rect="0 0 120 24" caption="{@st66b}{s18}이름{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="recipeTitle"/>
		<richtext name="recipeTitle_price" margin="422 0 0 0" rect="0 0 120 24" caption="{@st66b}{s18}단가{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="recipeTitle"/>
		<richtext name="recipeTitle_count" margin="580 0 0 0" rect="0 0 120 24" caption="{@st66b}{s18}구매 개수{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="recipeTitle"/>
		<richtext name="recipeTitle_totalPrice" margin="755 0 0 0" rect="0 0 120 24" caption="{@st66b}{s18}총 금액{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="recipeTitle"/>
		<richtext name="accessoryTitle_name" margin="90 0 0 0" rect="0 0 120 24" caption="{@st66b}{s18}이름{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="accessoryTitle"/>
		<richtext name="accessoryTitle_price" margin="768 0 0 0" rect="0 0 120 24" caption="{@st66b}{s18}금액{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="accessoryTitle"/>
		<richtext name="gemTitle_name" margin="90 0 0 0" rect="0 0 120 24" caption="{@st66b}{s18}이름{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="gemTitle"/>
		<richtext name="gemTitle_level" margin="389 0 0 0" rect="0 0 120 24" caption="{@st66b}{s18}레벨{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="gemTitle"/>
		<richtext name="gemTitle_roastingLv" margin="515 0 0 0" rect="0 0 120 24" caption="{@st66b}{s18}로스팅 레벨{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="gemTitle"/>
		<richtext name="gemTitle_price" margin="766 0 0 0" rect="0 0 120 24" caption="{@st66b}{s18}금액{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="gemTitle"/>
		<richtext name="cardTitle_name" margin="90 0 0 0" rect="0 0 120 24" caption="{@st66b}{s18}이름{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="cardTitle"/>
		<richtext name="cardTitle_level" margin="305 0 0 0" rect="0 0 120 24" caption="{@st66b}{s18}레벨{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="cardTitle"/>
		<richtext name="cardTitle_stats" margin="400 0 0 0" rect="0 0 120 24" caption="{@st66b}{s18}능력치{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="cardTitle"/>
		<richtext name="cardTitle_price" margin="766 0 0 0" rect="0 0 120 24" caption="{@st66b}{s18}금액{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="cardTitle"/>
		<richtext name="exporbTitle_name" margin="90 0 0 0" rect="0 0 120 24" caption="{@st66b}{s18}이름{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="exporbTitle"/>
		<richtext name="exporbTitle_exp" margin="510 0 0 0" rect="0 0 120 24" caption="{@st66b}{s18}경험치{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="exporbTitle"/>
		<richtext name="exporbTitle_price" margin="765 0 0 0" rect="0 0 120 24" caption="{@st66b}{s18}금액{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="exporbTitle"/>
		<richtext name="recipeSearch_name" margin="90 0 0 0" rect="0 0 120 24" caption="{@st66b}{s18}이름{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="recipeSearchTitle"/>
		<richtext name="recipeSearch_level" margin="305 0 0 0" rect="0 0 120 24" caption="{@st66b}{s18}레벨{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="recipeSearchTitle"/>
		<richtext name="OPTMisc_name" margin="90 0 0 0" rect="0 0 120 24" caption="{@st66b}{s18}이름{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="OPTMiscTitle"/>
		<richtext name="OPTMisc_type" margin="510 0 0 0" rect="0 0 120 24" caption="{@st66b}{s18}종류{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="OPTMiscTitle"/>
		<richtext name="OPTMisc_price" margin="815 0 0 0" rect="0 0 120 24" caption="{@st66b}{s18}금액{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="OPTMiscTitle"/>
		<richtext name="recipeSearch_price" margin="422 0 0 0" rect="0 0 120 24" sharedConst="USE_MARKET_REPORT/0" caption="{@st66b}{s18}단가{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="recipeSearchTitle"/>
		<richtext name="recipeSearch_price" margin="422 0 0 0" rect="0 0 120 24" sharedConst="USE_MARKET_REPORT/1" caption="{@st66b}{s18}단가{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="recipeSearchTitle"/>
		<richtext name="recipeSearch_cnt" margin="580 0 0 0" rect="0 0 120 24" sharedConst="USE_MARKET_REPORT/0" caption="{@st66b}{s18}구매개수{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="recipeSearchTitle"/>
		<richtext name="recipeSearch_cnt" margin="580 0 0 0" rect="0 0 120 24" sharedConst="USE_MARKET_REPORT/1" caption="{@st66b}{s18}구매개수{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="recipeSearchTitle"/>
		<richtext name="recipeSearch_totalPrice" margin="755 0 0 0" rect="0 0 120 24" sharedConst="USE_MARKET_REPORT/0" caption="{@st66b}{s18}총 금액{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="recipeSearchTitle"/>
		<richtext name="recipeSearch_totalPrice" margin="755 0 0 0" rect="0 0 120 24" sharedConst="USE_MARKET_REPORT/1" caption="{@st66b}{s18}총 금액{/}" textalign="center center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="recipeSearchTitle"/>
		<richtext name="recipeSearch_tempTitle" margin="3 0 0 0" rect="0 0 120 24" caption="{@st66b}{s18}제작 재료{/}" textalign="left center" resizebytext="true" spacey="0" maxwidth="0" fontname="white_16_ol" fixwidth="false" updateparent="false" drawbackground="false" slideshow="false" layout_gravity="left center" parent="recipeSearchTemp"/>
		<labelline name="labelline" margin="0 0 0 0" rect="0 0 1060 2" parent="recipeSearchTemp" skin="labelline2" layout_gravity="center top"/>
		<richtext name="t" rect="0 0 100 30" margin="0 33 0 0" layout_gravity="center top" caption="{@st43}{s24}마켓{/}" drawbackground="false" fixwidth="false" fontname="white_16_ol" maxwidth="0" resizebytext="true" slideshow="false" spacey="0" textalign="center center" updateparent="false"/>
		<controlset name="marketCategory" type="market_category" rect="0 0 335 873" margin="10 153 0 0" layout_gravity="left top"/>
		<!-- option config -->
		<groupbox name="optionBox" rect="0 0 450 300" margin="345 0 0 0" layout_gravity="left center" skin="test_frame_low" hittest="true"/>
		<button name="closeOptionBtn" parent="optionBox" rect="0 0 44 44" margin="0 15 15 0" layout_gravity="right top" LBtnUpScp="MARKET_OPTION_BOX_CLOSE_CLICK" clicksound="button_click_big" image="testclose_button" oversound="button_over" texttooltip="{@st59}검색 옵션 창을 닫습니다{/}" MouseOffAnim="btn_mouseoff" MouseOnAnim="btn_mouseover"/>
		<groupbox name="optionSaveBox" parent="optionBox" rect="0 0 450 300" margin="0 0 0 0" layout_gravity="center top" draw="false" hittestbox="false"/>
		<richtext name="saveStaticText" parent="optionSaveBox" rect="0 0 300 30" margin="0 85 0 0" layout_gravity="center top" caption="현재 카테고리 검색 옵션을 저장합니다.{nl}값을 입력하지 않은 설정들은 저장되지 않습니다." fontname="brown_16_b" textalign="center top"/>
		<picture name="save_titletextline" parent="optionSaveBox" rect="0 0 450 40" margin="7 15 0 0" layout_gravity="left top" hittest="false" image="test_com_namebg"/>
		<richtext name="savenametext" parent="optionSaveBox" rect="0 0 300 30" margin="0 145 0 0" layout_gravity="center top" caption="저장 이름" fontname="brown_16_b"/>
		<richtext name="titletext" rect="0 0 120 24" margin="10 0 0 0" parent="save_titletextline" layout_gravity="left center" caption="{@st66d}옵션 저장" drawbackground="false" fixwidth="false" fontname="black_20" maxwidth="0" resizebytext="true" slideshow="false" spacey="0" textalign="center center" updateparent="false" hittest="false"/>
		<edit name="saveConfigNameEdit" parent="optionSaveBox" rect="0 0 300 30" margin="0 170 0 0" layout_gravity="center top" skin="test_weight_skin" fontname="white_16_ol" textalign="center center"/>
		<button name="saveCommitBtn" parent="optionSaveBox" rect="0 0 200 50" margin="0 0 0 20" layout_gravity="center bottom" skin="test_red_button" caption="{@st41d}저장" fontname="white_16_ol" LBtnUpScp="MARKET_SAVE_CATEGORY_OPTION"/>
		<groupbox name="optionLoadBox" parent="optionBox" rect="0 0 450 300" margin="0 0 0 0" layout_gravity="center top" draw="false" hittestbox="false"/>
		<richtext name="loadStaticText" parent="optionLoadBox" rect="0 0 300 30" margin="0 85 0 0" layout_gravity="center top" caption="카테고리 옵션을 불러옵니다." fontname="brown_16_b"/>
		<picture name="load_titletextline" parent="optionLoadBox" rect="0 0 450 40" margin="7 15 0 0" layout_gravity="left top" hittest="false" image="test_com_namebg"/>
		<richtext name="titletext" rect="0 0 120 24" margin="10 0 0 0" parent="load_titletextline" layout_gravity="left center" caption="{@st66d}옵션 불러오기" drawbackground="false" fixwidth="false" fontname="black_20" maxwidth="0" resizebytext="true" slideshow="false" spacey="0" textalign="center center" updateparent="false" hittest="false"/>
		<groupbox name="optionListBox" parent="optionLoadBox" rect="0 0 433 150" margin="-4 0  0 10" layout_gravity="center bottom" skin="test_frame_midle"/>
	</controls>]] -- </uiframe> 
g_titleGboxList = {"defaultTitle", "equipTitle", "recipeTitle", "accessoryTitle", "gemTitle", "cardTitle",
                   "exporbTitle", "OPTMiscTitle"};

function MARKET_ON_INIT(addon, frame)
    addon:RegisterMsg("MARKET_ITEM_LIST", "ON_MARKET_ITEM_LIST");
    addon:RegisterMsg("OPEN_DLG_MARKET", "ON_OPEN_MARKET");
end

function ON_OPEN_MARKET(frame)
    local mapClsName = session.GetMapName()
    local mapCls = GetClass('Map', mapClsName)
    if TryGetProp(mapCls, 'MapType', 'None') ~= 'City' then
        ui.SysMsg(ClMsg('AllowedInTown'))
        return
    end

    MARKET_BUYMODE(frame)
    MARKET_FIRST_OPEN(frame);
    ui.OpenFrame("inventory");
end

function MARKET_FIRST_OPEN(frame)
    -- 마켓 이용 중에는 자동매칭중이면 간소화!
    local indunenter = ui.GetFrame('indunenter');
    if indunenter ~= nil and indunenter:IsVisible() == 1 then
        INDUNENTER_SMALL(indunenter, nil, true);
    end

    MARKET_RESET_LIST(frame);
    pc.ReqExecuteTx('GUIDE_QUEST_OPEN_UI', frame:GetName())
end

function MARKET_RESET_LIST(frame)
    MARKET_CLEAR_RECIPE_SEARCHLIST(frame);
    MARKET_INIT_CATEGORY(frame);
    session.market.ClearItems();
    session.market.ClearRecipeSearchList();
    ON_MARKET_ITEM_LIST(frame, 'MARKET_ITEM_LIST');
end

local function RESET_MARKET_OPTION(frame)
    frame:SetUserValue('SELECTED_CATEGORY', 'None');
    frame:SetUserValue('SELECTED_SUB_CATEGORY', 'None');
end

function MARKET_CLOSE(frame)
    TRADE_DIALOG_CLOSE();
    RESET_MARKET_OPTION(frame);

    local marketSellFrame = ui.GetFrame("market_sell");
    if marketSellFrame ~= nil then
        MARKET_SELL_FILTER_RESET(marketSellFrame);
    end
end

function RECIPE_SEARCH_FIND_PAGE(frame, page)
    local recipeSearchGbox = GET_CHILD_RECURSIVELY(frame, "recipeSearchGbox");
    local itemClassName = recipeSearchGbox:GetUserValue("itemClassName");
    local recipeCls = GetClass("Recipe", itemClassName)
    if recipeCls == nil then
        return
    end
    MARKET_REQ_RECIPE_LIST(frame, page, recipeCls);
end

function MARKET_CLEAR_RECIPE_SEARCHLIST(frame)
    local recipeGboxHeight = frame:GetUserConfig("RECIPE_BG_HEIGHT")

    local recipeBG = GET_CHILD_RECURSIVELY(frame, "market_midle3")
    local recipeGbox = GET_CHILD_RECURSIVELY(frame, "itemListGbox")
    local materialBG = GET_CHILD_RECURSIVELY(frame, "market_material_bg")
    local materialGbox = GET_CHILD_RECURSIVELY(frame, "recipeSearchGbox")
    local pageControl = GET_CHILD_RECURSIVELY(frame, "pagecontrol")
    local recipePageControl = GET_CHILD_RECURSIVELY(frame, "pagecontrol_recipe")
    local recipeSearchTitle = GET_CHILD_RECURSIVELY(frame, "recipeSearchTitle")
    local materialPageControl = GET_CHILD_RECURSIVELY(frame, "pagecontrol_material")
    local recipeSearchTemp = GET_CHILD_RECURSIVELY(frame, "recipeSearchTemp")

    materialBG:ShowWindow(0)
    materialGbox:ShowWindow(0)
    recipeSearchTitle:ShowWindow(0)
    local margin = recipePageControl:GetOriginalMargin()
    recipePageControl:ShowWindow(0)
    recipeBG:Resize(recipeBG:GetWidth(), recipeGboxHeight)
    recipeGbox:Resize(recipeGbox:GetWidth(), recipeGboxHeight - 35)
    materialPageControl:ShowWindow(0)
    recipeSearchTemp:ShowWindow(0)
    pageControl:ShowWindow(1)

    frame:SetUserValue("searchListIndex", 0)
    frame:SetUserValue("isRecipeSearching", 0)

end

function MARKET_PAGE_SELECT_NEXT(pageControl, numCtrl)
    pageControl = tolua.cast(pageControl, "ui::CPageController");
    local page = pageControl:GetCurPage();
    local frame = pageControl:GetTopParentFrame();
    MARKET_FIND_PAGE(frame, page);
end

function MARKET_PAGE_SELECT_PREV(pageControl, numCtrl)
    pageControl = tolua.cast(pageControl, "ui::CPageController");
    local page = pageControl:GetCurPage();
    local frame = pageControl:GetTopParentFrame();
    MARKET_FIND_PAGE(frame, page);
end

function MARKET_PAGE_SELECT(pageControl, numCtrl)
    pageControl = tolua.cast(pageControl, "ui::CPageController");
    local page = pageControl:GetCurPage();
    local frame = pageControl:GetTopParentFrame();
    MARKET_FIND_PAGE(frame, page);
end

function RECIPE_SEARCH_PAGE_SELECT_NEXT(pageControl, numCtrl)
    pageControl = tolua.cast(pageControl, "ui::CPageController");
    local page = pageControl:GetCurPage();
    local frame = pageControl:GetTopParentFrame();
    frame:SetUserValue("isRecipeSearching", 2)
    MARKET_FIND_PAGE(frame, page);
end

function RECIPE_SEARCH_SELECT_PREV(pageControl, numCtrl)
    pageControl = tolua.cast(pageControl, "ui::CPageController");
    local page = pageControl:GetCurPage();
    local frame = pageControl:GetTopParentFrame();
    frame:SetUserValue("isRecipeSearching", 2)
    MARKET_FIND_PAGE(frame, page);
end

function RECIPE_SEARCH_PAGE_SELECT(pageControl, numCtrl)
    pageControl = tolua.cast(pageControl, "ui::CPageController");
    local page = pageControl:GetCurPage();
    local frame = pageControl:GetTopParentFrame();
    frame:SetUserValue("isRecipeSearching", 2)
    MARKET_FIND_PAGE(frame, page);
end

function MATERIAL_SEARCH_PAGE_SELECT_NEXT(pageControl, numCtrl)
    pageControl = tolua.cast(pageControl, "ui::CPageController");
    local page = pageControl:GetCurPage();
    local frame = pageControl:GetTopParentFrame();
    RECIPE_SEARCH_FIND_PAGE(frame, page);
end

function MATERIAL_SEARCH_SELECT_PREV(pageControl, numCtrl)
    pageControl = tolua.cast(pageControl, "ui::CPageController");
    local page = pageControl:GetCurPage();
    local frame = pageControl:GetTopParentFrame();
    RECIPE_SEARCH_FIND_PAGE(frame, page);
end

function MATERIAL_SEARCH_PAGE_SELECT(pageControl, numCtrl)
    pageControl = tolua.cast(pageControl, "ui::CPageController");
    local page = pageControl:GetCurPage();
    local frame = pageControl:GetTopParentFrame();
    RECIPE_SEARCH_FIND_PAGE(frame, page);
end

local function MARKET_SET_PAGE_CONTROL(frame, pageControl)
    local category, _category, _subCategory = GET_CATEGORY_STRING(frame);
    local itemCntPerPage = GET_MARKET_SEARCH_ITEM_COUNT(_category);
    local maxPage = math.ceil(session.market.GetTotalCount() / itemCntPerPage);
    local curPage = session.market.GetCurPage();
    local pageController = GET_CHILD(frame, pageControl, 'ui::CPageController')
    if maxPage < 1 then
        maxPage = 1;
    end

    pageController:SetMaxPage(maxPage);
    pageController:SetCurPage(curPage);
end

function ON_MARKET_ITEM_LIST(frame, msg, argStr, argNum)
    if frame:IsVisible() == 0 then
        return;
    end

    local groupName = frame:GetUserValue('SELECTED_CATEGORY');
    local isRecipeSearching = frame:GetUserIValue("isRecipeSearching")
    if isRecipeSearching == 1 then
        MARKET_DRAW_CTRLSET_RECIPE(frame);
        MARKET_DRAW_CTRLSET_RECIPE_SEARCHLIST(frame)
    elseif isRecipeSearching == 2 then -- 제작서 재료 검색후 제작서 페이지 넘기는 경우
        MARKET_DRAW_CTRLSET_RECIPE(frame)
    else
        MARKET_CLEAR_RECIPE_SEARCHLIST(frame)

        if groupName == "ShowAll" then
            MARKET_DRAW_CTRLSET_DEFAULT(frame)
        elseif groupName == "Weapon" or groupName == "SubWeapon" or groupName == 'Accessory' or groupName == 'HairAcc' then
            local isShowSocket = true;
            if groupName == 'HairAcc' then
                isShowSocket = false;
            end
            MARKET_DRAW_CTRLSET_EQUIP(frame, isShowSocket);
        elseif groupName == "Armor" then
            MARKET_DRAW_CTRLSET_EQUIP(frame)
        elseif groupName == "Recipe" then
            MARKET_DRAW_CTRLSET_RECIPE(frame)
        elseif groupName == "Look" or groupName == "ChangeEquip" then
            MARKET_DRAW_CTRLSET_ACCESSORY(frame)
        elseif groupName == "Gem" then
            MARKET_DRAW_CTRLSET_GEM(frame)
        elseif groupName == "Card" then
            local subCategory = frame:GetUserValue('SELECTED_SUB_CATEGORY');
            if subCategory == "ShowAll" then
                MARKET_DRAW_CTRLSET_DEFAULT(frame)
            elseif subCategory == "CardAddExp" or subCategory == "Summon" then
                MARKET_DRAW_CTRLSET_DEFAULT(frame, false)
            else
                MARKET_DRAW_CTRLSET_CARD(frame)
            end
        elseif groupName == "ExpOrb" or groupName == "SubExpOrb" then
            MARKET_DRAW_CTRLSET_EXPORB(frame)
        elseif groupName == 'OPTMisc' then
            MARKET_DRAW_CTRLSET_OPTMISC(frame)
        else
            MARKET_DRAW_CTRLSET_DEFAULT(frame, false)
        end
    end
end

local function MARKET_CTRLSET_SET_ICON(ctrlSet, itemObj, marketItem)
    local pic = GET_CHILD_RECURSIVELY(ctrlSet, "pic");
    SET_SLOT_ITEM_CLS(pic, itemObj)
    SET_ITEM_TOOLTIP_ALL_TYPE(pic:GetIcon(), marketItem, itemObj.ClassName, "market", marketItem.itemType,
                              marketItem:GetMarketGuid());
    SET_SLOT_STYLESET(pic, itemObj)
    -- 아이커 종류 표시	
    SET_SLOT_ICOR_CATEGORY(pic, itemObj);

    if itemObj.MaxStack > 1 then
        local font = '{s16}{ol}{b}';
        if 100000 <= marketItem.count then -- 6자리 수 폰트 크기 조정
            font = '{s14}{ol}{b}';
        end
        SET_SLOT_COUNT_TEXT(pic, marketItem.count, font);
    end
    SET_SLOT_STAR_TEXT(pic, itemObj);
end

function MARKET_CTRLSET_SET_PRICE(ctrlSet, marketItem)
    local priceStr = marketItem:GetSellPrice();
    local price_num = ctrlSet:GetChild("price_num");
    price_num:SetTextByKey("value", GET_COMMAED_STRING(priceStr));
    price_num:SetUserValue("Price", priceStr);

    local price_text = ctrlSet:GetChild("price_text");
    price_text:SetTextByKey("value", GetMonetaryString(priceStr));

    ctrlSet:SetUserValue("sellPrice", priceStr);
end

function MARKET_CTRLSET_SET_TOTAL_PRICE(ctrlSet, marketItem)
    local priceStr = marketItem:GetSellPrice();
    local totalPrice_num = GET_CHILD_RECURSIVELY(ctrlSet, "totalPrice_num");
    if totalPrice_num ~= nil then
        totalPrice_num:SetTextByKey("value", GET_COMMAED_STRING(priceStr));
        totalPrice_num:SetUserValue("Price", priceStr);
    end

    local totalPrice_text = GET_CHILD_RECURSIVELY(ctrlSet, "totalPrice_text");
    if totalPrice_text ~= nil then
        totalPrice_text:SetTextByKey("value", GetMonetaryString(priceStr));
    end
end

function MARKET_DRAW_CTRLSET_DEFAULT(frame, isShowLevel)
    local itemlist = GET_CHILD_RECURSIVELY(frame, "itemListGbox");
    itemlist:RemoveAllChild();
    local mySession = session.GetMySession();
    local cid = mySession:GetCID();
    local count = session.market.GetItemCount();

    MARKET_SELECT_SHOW_TITLE(frame, "defaultTitle")
    local defaultTitle_level = GET_CHILD_RECURSIVELY(frame, "defaultTitle_level")
    if isShowLevel ~= nil and isShowLevel == false then
        defaultTitle_level:ShowWindow(0)
    else
        defaultTitle_level:ShowWindow(1)
    end

    local yPos = 0
    for i = 0, count - 1 do
        local marketItem = session.market.GetItemByIndex(i);
        local itemObj = GetIES(marketItem:GetObject());
        local refreshScp = itemObj.RefreshScp;
        if refreshScp ~= "None" then
            refreshScp = _G[refreshScp];
            refreshScp(itemObj);
        end

        local ctrlSet = itemlist:CreateControlSet("market_item_detail_default", "ITEM_EQUIP_" .. i, ui.LEFT, ui.TOP, 0,
                                                  0, 0, yPos);
        AUTO_CAST(ctrlSet)
        ctrlSet:SetUserValue("DETAIL_ROW", i);

        MARKET_CTRLSET_SET_ICON(ctrlSet, itemObj, marketItem);

        if itemObj.GroupName == "ExpOrb" or itemObj.GroupName == "SubExpOrb" then
            local curExp, maxExp = GET_LEGENDEXPPOTION_EXP(itemObj)
            local expPoint = 0
            if maxExp ~= nil and maxExp ~= 0 then
                expPoint = curExp / maxExp * 100
            else
                expPoint = 0
            end
            local expStr = string.format("%.2f", expPoint)

            MARKET_SET_EXPORB_ICON(ctrlSet, curExp, maxExp, itemObj)
        end

        local name = ctrlSet:GetChild("name");
        local name_text = GET_FULL_NAME(itemObj)
        local grade = shared_item_earring.get_earring_grade(itemObj)
        if grade > 0 then
            name_text = name_text .. '(' .. grade .. ClMsg('Grade') .. ')'
        end

        name:SetTextByKey("value", name_text);

        local level = ctrlSet:GetChild("level");
        local levelValue = ""
        if isShowLevel ~= false then
            if itemObj.GroupName == "Gem" then
                levelValue = GET_ITEM_LEVEL_EXP(itemObj)
            elseif itemObj.GroupName == "Card" then
                levelValue = itemObj.Level
            elseif itemObj.ItemType == "Equip" and TryGetProp(itemObj, 'ClassType2') ~= "Premium" then
                levelValue = itemObj.UseLv
            end
        end
        level:SetTextByKey("value", levelValue);

        MARKET_CTRLSET_SET_PRICE(ctrlSet, marketItem, cid);

        if cid == marketItem:GetSellerCID() then
            local buyBtn = GET_CHILD_RECURSIVELY(ctrlSet, "buyBtn");
            buyBtn:ShowWindow(0)
            buyBtn:SetEnable(0);
            local cancelBtn = GET_CHILD_RECURSIVELY(ctrlSet, "cancelBtn");
            cancelBtn:ShowWindow(1)
            cancelBtn:SetEnable(1)

            if USE_MARKET_REPORT == 1 then
                local reportBtn = ctrlSet:GetChild("reportBtn");
                reportBtn:SetEnable(0);
            end

            local totalPrice_num = ctrlSet:GetChild("totalPrice_num");
            totalPrice_num:SetTextByKey("value", 0);
            local totalPrice_text = ctrlSet:GetChild("totalPrice_text");
            totalPrice_text:SetTextByKey("value", 0);
        else
            local buyBtn = GET_CHILD_RECURSIVELY(ctrlSet, "buyBtn");
            buyBtn:ShowWindow(1)
            buyBtn:SetEnable(1);
            local cancelBtn = GET_CHILD_RECURSIVELY(ctrlSet, "cancelBtn");
            cancelBtn:ShowWindow(0)
            cancelBtn:SetEnable(0)

            local editCount = GET_CHILD_RECURSIVELY(ctrlSet, "count")
            editCount:SetMinNumber(1)
            editCount:SetMaxNumber(marketItem.count)
            editCount:SetText("1")
            editCount:SetNumChangeScp("MARKET_CHANGE_COUNT");
            ctrlSet:SetUserValue("minItemCount", 1)
            ctrlSet:SetUserValue("maxItemCount", marketItem.count)

            MARKET_CTRLSET_SET_TOTAL_PRICE(ctrlSet, marketItem);
        end
    end

    local ITEM_CTRLSET_INTERVAL_Y_MARGIN = tonumber(frame:GetUserConfig('ITEM_CTRLSET_INTERVAL_Y_MARGIN'));
    GBOX_AUTO_ALIGN(itemlist, 4, ITEM_CTRLSET_INTERVAL_Y_MARGIN, 0, false, true);

    MARKET_SET_PAGE_CONTROL(frame, "pagecontrol")
end

local function _CREATE_SEAL_OPTION(ctrlSet, itemObj)
    if TryGetProp(itemObj, 'GroupName') ~= 'Seal' then
        return;
    end

    if TryGetProp(itemObj, "StringArg") == "Seal_Material" then
        return;
    end

    for i = 1, itemObj.MaxReinforceCount do
        local option = TryGetProp(itemObj, 'SealOption_' .. i, 'None');
        if option == 'None' then
            break
        end
        local strInfo = GET_OPTION_VALUE_OR_PERCECNT_STRING(option, itemObj['SealOptionValue_' .. i]);
        SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
    end
end

local function _CREATE_EARRING_OPTION(ctrlSet, itemObj)
    if TryGetProp(itemObj, 'GroupName') ~= 'Earring' then
        return;
    end

    for i = 1, shared_item_earring.get_max_special_option_count(TryGetProp(itemObj, 'ItemLv', 0)) do
        local ctrl = TryGetProp(itemObj, 'EarringSpecialOption_' .. i, 'None')
        if ctrl ~= 'None' then
            local cls = GetClass('Job', ctrl)
            local ctrl = TryGetProp(cls, 'Name', 'None')

            local rank = TryGetProp(itemObj, 'EarringSpecialOptionRankValue_' .. i, 0)
            local lv = TryGetProp(itemObj, 'EarringSpecialOptionLevelValue_' .. i, 0)
            local text = ScpArgMsg('EarringSpecialOption{ctrl}{rank}{lv}', 'ctrl', ctrl, 'rank', rank, 'lv', lv)
            SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, text);
        end
    end
end

local function _CREATE_RADA_OPTION(ctrlSet, itemObj)
    if TryGetProp(itemObj, 'RadaOption', 'None') == 'None' then
        return;
    end

    local RadaOption = TryGetProp(itemObj, 'RadaOption', 'None')
    local equip_group = TryGetProp(itemObj, 'EquipGroup', 'None')
    if RadaOption ~= 'None' then

        local list = StringSplit(RadaOption, ';')
        for i = 1, #list do
            local desc = ''
            local prefix = ''
            local suffix = ''
            if SEASON_COIN_NAME ~= 'RadaCertificate' then
                prefix = '{#7F7F7F}'
                suffix = '{/}'
            end

            desc = prefix .. desc

            local name = StringSplit(list[i], '/')[1]
            local value = StringSplit(list[i], '/')[2]

            local range = GET_RADAOPTION_RANGE(name, equip_group)
            desc = desc .. ScpArgMsg(name, 'level', value, 'min', range[1], 'max', range[2]) .. '{nl}'
            desc = desc .. suffix
            SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, desc);
        end
    end
end

function MARKET_DRAW_CTRLSET_EQUIP(frame, isShowSocket)
    local itemlist = GET_CHILD_RECURSIVELY(frame, "itemListGbox");
    itemlist:RemoveAllChild();
    local mySession = session.GetMySession();
    local cid = mySession:GetCID();
    local count = session.market.GetItemCount();

    MARKET_SELECT_SHOW_TITLE(frame, "equipTitle")

    local equipTitle_socket = GET_CHILD_RECURSIVELY(frame, "equipTitle_socket");
    local equipTitle_stats = GET_CHILD_RECURSIVELY(frame, "equipTitle_stats");
    if isShowSocket ~= nil and isShowSocket == false then
        equipTitle_socket:ShowWindow(0);
        equipTitle_stats:ShowWindow(0);
    else
        equipTitle_socket:ShowWindow(1)
        equipTitle_stats:ShowWindow(1);
    end

    local yPos = 0
    for i = 0, count - 1 do
        local marketItem = session.market.GetItemByIndex(i);
        local itemObj = GetIES(marketItem:GetObject());
        local refreshScp = itemObj.RefreshScp;
        if refreshScp ~= "None" then
            refreshScp = _G[refreshScp];
            refreshScp(itemObj);
        end

        local ctrlSet = itemlist:CreateControlSet("market_item_detail_equip", "ITEM_EQUIP_" .. i, ui.LEFT, ui.TOP, 0, 0,
                                                  0, yPos);
        AUTO_CAST(ctrlSet)
        ctrlSet:SetUserValue("DETAIL_ROW", i);
        ctrlSet:SetUserValue("optionIndex", 0)

        local inheritanceItem = GetClass('Item', itemObj.InheritanceItemName)
        if inheritanceItem == nil then
            inheritanceItem = GetClass('Item', itemObj.InheritanceRandomItemName)
        end

        MARKET_CTRLSET_SET_ICON(ctrlSet, itemObj, marketItem);

        local name = GET_CHILD_RECURSIVELY(ctrlSet, "name");
        local name_text = GET_FULL_NAME(itemObj)
        local grade = shared_item_earring.get_earring_grade(itemObj)
        if grade > 0 then
            name_text = name_text .. '(' .. grade .. ClMsg('Grade') .. ')'
        end

        name:SetTextByKey("value", name_text);

        local level = GET_CHILD_RECURSIVELY(ctrlSet, "level");
        level:SetTextByKey("value", itemObj.UseLv);

        -- ATK, MATK, DEF 
        local atkdefImageSize = ctrlSet:GetUserConfig("ATKDEF_IMAGE_SIZE")
        local basicProp = 'None';
        local atkdefText = "";
        if itemObj.BasicTooltipProp ~= 'None' then
            local basicTooltipPropList = StringSplit(itemObj.BasicTooltipProp, ';');
            for i = 1, #basicTooltipPropList do
                basicProp = basicTooltipPropList[i];
                if basicProp == 'ATK' then
                    typeiconname = 'test_sword_icon'
                    typestring = ScpArgMsg("Melee_Atk")
                    if TryGetProp(itemObj, 'EquipGroup') == "SubWeapon" then
                        typestring = ScpArgMsg("PATK_SUB")
                    end
                    arg1 = itemObj.MINATK;
                    arg2 = itemObj.MAXATK;
                elseif basicProp == 'MATK' then
                    typeiconname = 'test_sword_icon'
                    typestring = ScpArgMsg("Magic_Atk")
                    arg1 = itemObj.MATK;
                    arg2 = itemObj.MATK;
                else
                    typeiconname = 'test_shield_icon'
                    typestring = ScpArgMsg(basicProp);
                    if itemObj.RefreshScp ~= 'None' then
                        local scp = _G[itemObj.RefreshScp];
                        if scp ~= nil then
                            scp(itemObj);
                        end
                    end

                    arg1 = TryGetProp(itemObj, basicProp);
                    arg2 = TryGetProp(itemObj, basicProp);
                end

                local tempStr = string.format("{img %s %d %d}", typeiconname, atkdefImageSize, atkdefImageSize)
                local tempATKDEF = ""
                if arg1 == arg2 or arg2 == 0 then
                    tempATKDEF = " " .. arg1
                else
                    tempATKDEF = " " .. arg1 .. "~" .. arg2
                end

                if i == 1 then
                    atkdefText = atkdefText .. tempStr .. typestring .. tempATKDEF
                else
                    atkdefText = atkdefText .. "{nl}" .. tempStr .. typestring .. tempATKDEF
                end
            end
        end

        local atkdef = GET_CHILD_RECURSIVELY(ctrlSet, "atkdef");
        atkdef:SetTextByKey("value", atkdefText);

        -- SOCKET

        local socket = GET_CHILD_RECURSIVELY(ctrlSet, "socket")

        local needAppraisal = TryGetProp(itemObj, "NeedAppraisal");
        local needRandomOption = TryGetProp(itemObj, "NeedRandomOption");
        local maxSocketCount = itemObj.MaxSocket
        local drawFlag = 0
        if maxSocketCount > 3 then
            drawFlag = 1
        end

        local curCount = 1;
        local socketText = "";
        local tempStr = "";
        for i = 0, maxSocketCount - 1 do
            if marketItem:IsAvailableSocket(i) == true then
                local isEquip = marketItem:GetEquipGemID(i);
                if isEquip == 0 then
                    tempStr = ctrlSet:GetUserConfig("SOCKET_IMAGE_EMPTY")
                    if drawFlag == 1 and curCount % 2 == 1 then
                        socketText = socketText .. tempStr
                    else
                        socketText = socketText .. tempStr .. "{nl}"
                    end
                else
                    local gemClass = GetClassByType("Item", isEquip);
                    if gemClass.ClassName == 'gem_circle_1' then
                        tempStr = ctrlSet:GetUserConfig("SOCKET_IMAGE_RED")
                    elseif gemClass.ClassName == 'gem_square_1' then
                        tempStr = ctrlSet:GetUserConfig("SOCKET_IMAGE_BLUE")
                    elseif gemClass.ClassName == 'gem_diamond_1' then
                        tempStr = ctrlSet:GetUserConfig("SOCKET_IMAGE_GREEN")
                    elseif gemClass.ClassName == 'gem_star_1' then
                        tempStr = ctrlSet:GetUserConfig("SOCKET_IMAGE_YELLOW")
                    elseif gemClass.ClassName == 'gem_White_1' then
                        tempStr = ctrlSet:GetUserConfig("SOCKET_IMAGE_WHITE")
                    elseif gemClass.EquipXpGroup == "Gem_Skill" then
                        tempStr = ctrlSet:GetUserConfig("SOCKET_IMAGE_MONSTER")
                    end

                    local gemLv = GET_ITEM_LEVEL_EXP(gemClass, marketItem:GetEquipGemExp(i));
                    tempStr = tempStr .. "Lv" .. gemLv

                    if drawFlag == 1 and curCount % 2 == 1 then
                        socketText = socketText .. tempStr
                    else
                        socketText = socketText .. tempStr .. "{nl}"
                    end
                end
            end
            curCount = curCount + 1
        end
        socket:SetTextByKey("value", socketText)

        -- POTENTIAL

        local potential = GET_CHILD_RECURSIVELY(ctrlSet, "potential");
        if needAppraisal == 1 then
            potential:SetTextByKey("value1", "?")
            potential:SetTextByKey("value2", "?")
        else
            potential:SetTextByKey("value1", itemObj.PR)
            potential:SetTextByKey("value2", itemObj.MaxPR)
        end

        -- OPTION

        local originalItemObj = itemObj
        if inheritanceItem ~= nil then
            itemObj = inheritanceItem
        end

        if needAppraisal == 1 or needRandomOption == 1 then
            SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, '{@st66b}' .. ScpArgMsg("AppraisalItem"))
        end

        local basicList = GET_EQUIP_TOOLTIP_PROP_LIST(itemObj);
        local list = {};
        local basicTooltipPropList = StringSplit(itemObj.BasicTooltipProp, ';');
        for i = 1, #basicTooltipPropList do
            local basicTooltipProp = basicTooltipPropList[i];
            list = GET_CHECK_OVERLAP_EQUIPPROP_LIST(basicList, basicTooltipProp, list);
        end

        local list2 = GET_EUQIPITEM_PROP_LIST();
        local cnt = 0;
        local class = GetClassByType("Item", itemObj.ClassID);

        local maxRandomOptionCnt = MAX_OPTION_EXTRACT_COUNT;
        local randomOptionProp = {};
        for i = 1, maxRandomOptionCnt do
            if itemObj['RandomOption_' .. i] ~= 'None' then
                randomOptionProp[itemObj['RandomOption_' .. i]] = itemObj['RandomOptionValue_' .. i];
            end
        end

        for i = 1, #list do
            local propName = list[i];
            local propValue = TryGetProp(class, propName, 0);

            local needToShow = true;
            for j = 1, #basicTooltipPropList do
                if basicTooltipPropList[j] == propName then
                    needToShow = false;
                end
            end

            if needToShow == true and propValue ~= 0 and randomOptionProp[propName] == nil then -- 랜덤 옵션이랑 겹치는 프로퍼티는 여기서 출력하지 않음
                if itemObj.GroupName == 'Weapon' then
                    if propName ~= "MINATK" and propName ~= 'MAXATK' then
                        local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), propValue);
                        SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                    end
                elseif itemObj.GroupName == 'Armor' then
                    if itemObj.ClassType == 'Gloves' then
                        if propName ~= "HR" then
                            local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), propValue);
                            SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                        end
                    elseif itemObj.ClassType == 'Boots' then
                        if propName ~= "DR" then
                            local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), propValue);
                            SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                        end
                    else
                        if propName ~= "DEF" then
                            local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), propValue);
                            SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                        end
                    end
                else
                    local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), propValue);
                    SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                end
            end
        end

        for i = 1, 3 do
            local propName = "HatPropName_" .. i;
            local propValue = "HatPropValue_" .. i;
            if itemObj[propValue] ~= 0 and itemObj[propName] ~= "None" then
                local opName
                if string.find(itemObj[propName], 'ALLSKILL_') == nil then
                    opName = string.format("[%s] %s", ClMsg("EnchantOption"), ScpArgMsg(itemObj[propName]));
                else
                    local token = StringSplit(itemObj[propName], '_')
                    local job = token[2]
                    if job == 'ShadowMancer' then
                        job = 'Shadowmancer'
                    end
                    opName = string.format("[%s] %s", ClMsg("EnchantOption"),
                                           ScpArgMsg(job) .. ' ' .. ScpArgMsg('skill_lv_up_by_count'));
                end

                local strInfo = ABILITY_DESC_PLUS(opName, itemObj[propValue]);
                SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
            end
        end

        for i = 1, maxRandomOptionCnt do
            local propGroupName = "RandomOptionGroup_" .. i;
            local propName = "RandomOption_" .. i;
            local propValue = "RandomOptionValue_" .. i;
            local clientMessage = 'None'

            local propItem = originalItemObj

            if propItem[propGroupName] == 'ATK' then
                clientMessage = 'ItemRandomOptionGroupATK'
            elseif propItem[propGroupName] == 'DEF' then
                clientMessage = 'ItemRandomOptionGroupDEF'
            elseif propItem[propGroupName] == 'UTIL_WEAPON' then
                clientMessage = 'ItemRandomOptionGroupUTIL'
            elseif propItem[propGroupName] == 'UTIL_ARMOR' then
                clientMessage = 'ItemRandomOptionGroupUTIL'
            elseif propItem[propGroupName] == 'UTIL_SHILED' then
                clientMessage = 'ItemRandomOptionGroupUTIL'
            elseif propItem[propGroupName] == 'STAT' then
                clientMessage = 'ItemRandomOptionGroupSTAT'
            elseif propItem[propGroupName] == 'SPECIAL' then
                clientMessage = 'ItemRandomOptionGroupSPECIAL'
                --[[elseif propItem[propGroupName] == 'SPECIAL' then
                clientMessage = 'ItemRandomOptionGroupSPECIAL']]
            end

            if propItem[propValue] ~= 0 and propItem[propName] ~= "None" then
                local opName = string.format("%s %s", ClMsg(clientMessage), ScpArgMsg(propItem[propName]));
                local strInfo = ABILITY_DESC_NO_PLUS(opName, propItem[propValue], 0);
                SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
            end
        end

        _CREATE_SEAL_OPTION(ctrlSet, itemObj);
        _CREATE_EARRING_OPTION(ctrlSet, itemObj);
        _CREATE_RADA_OPTION(ctrlSet, itemObj);

        for i = 1, #list2 do
            local propName = list2[i];
            local propValue = TryGetProp(itemObj, propName, 0);
            if propValue ~= 0 then
                local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), propValue);
                SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
            end
        end

        if itemObj.OptDesc ~= nil and itemObj.OptDesc ~= 'None' then
            SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, itemObj.OptDesc);
        end

        if originalItemObj['RandomOptionRareValue'] ~= 0 and originalItemObj['RandomOptionRare'] ~= "None" then
            local strInfo = _GET_RANDOM_OPTION_RARE_CLIENT_TEXT(originalItemObj['RandomOptionRare'],
                                                                originalItemObj['RandomOptionRareValue'], '');
            if strInfo ~= nil then
                SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
            end
        end

        if inheritanceItem == nil then
            if itemObj.IsAwaken == 1 then
                local opName = string.format("[%s] %s", ClMsg("AwakenOption"), ScpArgMsg(itemObj.HiddenProp));
                local strInfo = ABILITY_DESC_PLUS(opName, itemObj.HiddenPropValue);
                SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
            end
        else
            if inheritanceItem.IsAwaken == 1 then
                local opName = string.format("[%s] %s", ClMsg("AwakenOption"), ScpArgMsg(inheritanceItem.HiddenProp));
                local strInfo = ABILITY_DESC_PLUS(opName, inheritanceItem.HiddenPropValue);
                SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
            end
        end

        if itemObj.ReinforceRatio > 100 then
            local opName = ClMsg("ReinforceOption");
            local strInfo = ABILITY_DESC_PLUS(opName, math.floor(10 * itemObj.ReinforceRatio / 100));
            SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
        end

        -- 내 판매리스트 처리

        if cid == marketItem:GetSellerCID() then
            local buyBtn = GET_CHILD_RECURSIVELY(ctrlSet, "buyBtn");
            buyBtn:ShowWindow(0)
            buyBtn:SetEnable(0);
            local cancelBtn = GET_CHILD_RECURSIVELY(ctrlSet, "cancelBtn");
            cancelBtn:ShowWindow(1)
            cancelBtn:SetEnable(1)

            if USE_MARKET_REPORT == 1 then
                local reportBtn = GET_CHILD_RECURSIVELY(ctrlSet, "reportBtn");
                reportBtn:SetEnable(0);
            end

            local totalPrice_num = GET_CHILD_RECURSIVELY(ctrlSet, "totalPrice_num");
            totalPrice_num:SetTextByKey("value", 0);
            local totalPrice_text = GET_CHILD_RECURSIVELY(ctrlSet, "totalPrice_text");
            totalPrice_text:SetTextByKey("value", 0);
        else

            local buyBtn = GET_CHILD_RECURSIVELY(ctrlSet, "buyBtn");
            buyBtn:ShowWindow(1)
            buyBtn:SetEnable(1);
            local cancelBtn = GET_CHILD_RECURSIVELY(ctrlSet, "cancelBtn");
            cancelBtn:ShowWindow(0)
            cancelBtn:SetEnable(0)

            MARKET_CTRLSET_SET_TOTAL_PRICE(ctrlSet, marketItem);
        end

        ctrlSet:SetUserValue("sellPrice", marketItem:GetSellPrice());
    end

    local ITEM_CTRLSET_INTERVAL_Y_MARGIN = tonumber(frame:GetUserConfig('ITEM_CTRLSET_INTERVAL_Y_MARGIN'));
    GBOX_AUTO_ALIGN(itemlist, 4, ITEM_CTRLSET_INTERVAL_Y_MARGIN, 0, true, false);

    MARKET_SET_PAGE_CONTROL(frame, "pagecontrol")
end

function SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, str)
    local index = ctrlSet:GetUserIValue("optionIndex")
    local optionText = GET_CHILD_RECURSIVELY(ctrlSet, "randomoption_" .. index)

    if optionText == nil then
        return
    end

    optionText:SetTextByKey("value", str)
    if index < 7 then
        ctrlSet:SetUserValue("optionIndex", index + 1)
    elseif index == 7 then
        optionText = GET_CHILD_RECURSIVELY(ctrlSet, "randomoption_" .. index)
        optionText:SetTextByKey("value", ClMsg('RemainMoreOption'))
        ctrlSet:SetUserValue("optionIndex", index + 1)
    end
end

function MARKET_DRAW_CTRLSET_RECIPE(frame)
    local itemlist = GET_CHILD_RECURSIVELY(frame, "itemListGbox");
    itemlist:RemoveAllChild();
    local mySession = session.GetMySession();
    local cid = mySession:GetCID();
    local count = session.market.GetItemCount();

    MARKET_SELECT_SHOW_TITLE(frame, "recipeTitle")

    local yPos = 0
    for i = 0, count - 1 do
        local marketItem = session.market.GetItemByIndex(i);
        local itemObj = GetIES(marketItem:GetObject());
        local refreshScp = itemObj.RefreshScp;
        if refreshScp ~= "None" then
            refreshScp = _G[refreshScp];
            refreshScp(itemObj);
        end

        local ctrlSet = itemlist:CreateControlSet("market_item_detail_recipe", "ITEM_EQUIP_" .. i, ui.LEFT, ui.TOP, 0,
                                                  0, 0, yPos);
        AUTO_CAST(ctrlSet)
        ctrlSet:SetUserValue("DETAIL_ROW", i);
        ctrlSet:SetUserValue("itemClassName", itemObj.ClassName)

        MARKET_CTRLSET_SET_ICON(ctrlSet, itemObj, marketItem);

        local name = ctrlSet:GetChild("name");
        name:SetTextByKey("value", GET_FULL_NAME(itemObj));

        local count = ctrlSet:GetChild("count");
        count:SetTextByKey("value", marketItem.count);
        MARKET_CTRLSET_SET_PRICE(ctrlSet, marketItem);

        if cid == marketItem:GetSellerCID() then
            local buyBtn = GET_CHILD_RECURSIVELY(ctrlSet, "buyBtn");
            buyBtn:ShowWindow(0)
            buyBtn:SetEnable(0);
            local cancelBtn = GET_CHILD_RECURSIVELY(ctrlSet, "cancelBtn");
            cancelBtn:ShowWindow(1)
            cancelBtn:SetEnable(1)

            if USE_MARKET_REPORT == 1 then
                local reportBtn = ctrlSet:GetChild("reportBtn");
                reportBtn:SetEnable(0);
            end

            local totalPrice_num = ctrlSet:GetChild("totalPrice_num");
            totalPrice_num:SetTextByKey("value", 0);
            local totalPrice_text = ctrlSet:GetChild("totalPrice_text");
            totalPrice_text:SetTextByKey("value", 0);
        else

            local buyBtn = GET_CHILD_RECURSIVELY(ctrlSet, "buyBtn");
            buyBtn:ShowWindow(1)
            buyBtn:SetEnable(1);
            local cancelBtn = GET_CHILD_RECURSIVELY(ctrlSet, "cancelBtn");
            cancelBtn:ShowWindow(0)
            cancelBtn:SetEnable(0)

            local editCount = GET_CHILD_RECURSIVELY(ctrlSet, "count")
            editCount:SetMinNumber(1)
            editCount:SetMaxNumber(marketItem.count)
            editCount:SetText("1")
            editCount:SetNumChangeScp("MARKET_CHANGE_COUNT");
            ctrlSet:SetUserValue("minItemCount", 1)
            ctrlSet:SetUserValue("maxItemCount", marketItem.count)

            MARKET_CTRLSET_SET_TOTAL_PRICE(ctrlSet, marketItem);
        end

        ctrlSet:SetUserValue("marketItemGuid", marketItem:GetMarketGuid());
    end

    local itemlistHeight = itemlist:GetHeight()

    local ITEM_CTRLSET_INTERVAL_Y_MARGIN = tonumber(frame:GetUserConfig('ITEM_CTRLSET_INTERVAL_Y_MARGIN'));
    GBOX_AUTO_ALIGN(itemlist, 4, ITEM_CTRLSET_INTERVAL_Y_MARGIN, 0, false, true);
    if frame:GetUserIValue("isRecipeSearching") == 2 then
        frame:SetUserValue("isRecipeSearching", 1);
        local category, _category, _subCategory = GET_CATEGORY_STRING(frame);
        local itemCntPerPage = GET_MARKET_SEARCH_ITEM_COUNT(_category);
        local maxPage_recipe = math.ceil(session.market.GetTotalCount() / itemCntPerPage);
        local curPage_recipe = session.market.GetCurPage();
        local pagecontrol_recipe = GET_CHILD(frame, 'pagecontrol_recipe', 'ui::CPageController')
        if maxPage_recipe < 1 then
            maxPage_recipe = 1;
        end

        pagecontrol_recipe:SetMaxPage(maxPage_recipe);
        pagecontrol_recipe:SetCurPage(curPage_recipe);
    end
    itemlist:Resize(itemlist:GetWidth(), itemlistHeight)

    MARKET_SET_PAGE_CONTROL(frame, "pagecontrol")
end

function MARKET_DRAW_CTRLSET_RECIPE_SEARCH(ctrlSet)
    local frame = ui.GetFrame("market")
    if frame == nil then
        return
    end

    local searchBtn = GET_CHILD_RECURSIVELY(ctrlSet, "searchBtn");
    ui.DisableForTime(searchBtn, 1.5);

    frame:SetUserValue("isRecipeSearching", 1)
    frame:SetUserValue("searchListIndex", 0)

    local recipeBG = GET_CHILD_RECURSIVELY(frame, "market_midle3")
    local recipeGbox = GET_CHILD_RECURSIVELY(frame, "itemListGbox")
    local market_low = GET_CHILD_RECURSIVELY(frame, "market_low")
    local materialBG = GET_CHILD_RECURSIVELY(frame, "market_material_bg")
    local materialGbox = GET_CHILD_RECURSIVELY(frame, "recipeSearchGbox")
    local pageControl = GET_CHILD_RECURSIVELY(frame, "pagecontrol")
    local recipePageControl = GET_CHILD_RECURSIVELY(frame, "pagecontrol_recipe")
    local recipeSearchTitle = GET_CHILD_RECURSIVELY(frame, "recipeSearchTitle")
    local recipeSearchTemp = GET_CHILD_RECURSIVELY(frame, "recipeSearchTemp")

    materialBG:ShowWindow(1)
    materialGbox:ShowWindow(1)
    recipeSearchTitle:ShowWindow(1)
    materialGbox:SetUserValue("yPos", 0)
    materialGbox:RemoveAllChild();

    recipeBG:Resize(recipeBG:GetWidth(), market_low:GetHeight() / 4 + 10)
    recipeGbox:Resize(recipeGbox:GetWidth(), market_low:GetHeight() / 4 - 25)
    recipePageControl:ShowWindow(1)
    recipeSearchTemp:ShowWindow(1)
    pageControl:ShowWindow(0)

    local itemClassName = ctrlSet:GetUserValue("itemClassName")
    materialGbox:SetUserValue("itemClassName", itemClassName)
    local recipeCls = GetClass("Recipe", itemClassName)
    if recipeCls == nil then
        return
    end

    MARKET_SEARCH_RECIPE_IN_DETAIL_MODE(frame, pageControl, ctrlSet);
    MARKET_REQ_RECIPE_LIST(frame, 0, recipeCls);
end

function MARKET_DRAW_CTRLSET_RECIPE_SEARCHLIST(frame)
    local itemlist = GET_CHILD_RECURSIVELY(frame, "recipeSearchGbox");
    local mySession = session.GetMySession();
    local cid = mySession:GetCID();
    local count = session.market.GetRecipeSearchItemCount();

    DESTROY_CHILD_BYNAME(itemlist, "ITEM_MATERIAL_")

    local yPos = 0
    local index = 0
    for i = 0, count - 1 do
        local marketItem = session.market.GetRecipeSearchByIndex(i);
        local itemObj = GetIES(marketItem:GetObject());
        local refreshScp = itemObj.RefreshScp;
        if refreshScp ~= "None" then
            refreshScp = _G[refreshScp];
            refreshScp(itemObj);
        end

        local ctrlSet = itemlist:CreateControlSet("market_item_detail_default", "ITEM_MATERIAL_" .. index, ui.LEFT,
                                                  ui.TOP, 0, 0, 0, yPos);
        AUTO_CAST(ctrlSet)

        ctrlSet:SetUserValue("marketRecipeSearchGuid", marketItem:GetMarketGuid())
        ctrlSet:SetUserValue("DETAIL_ROW", index);
        index = index + 1
        frame:SetUserValue("searchListIndex", index)

        MARKET_CTRLSET_SET_ICON(ctrlSet, itemObj, marketItem);

        local name = ctrlSet:GetChild("name");
        name:SetTextByKey("value", GET_FULL_NAME(itemObj));

        local count = ctrlSet:GetChild("count");
        count:SetTextByKey("value", marketItem.count);

        local level = ctrlSet:GetChild("level");
        level:SetTextByKey("value", itemObj.UseLv);

        MARKET_CTRLSET_SET_PRICE(ctrlSet, marketItem);

        local reportBtn = ctrlSet:GetChild("reportBtn")
        reportBtn:ShowWindow(0)

        if cid == marketItem:GetSellerCID() then
            local buyBtn = GET_CHILD_RECURSIVELY(ctrlSet, "buyBtn");
            buyBtn:ShowWindow(0)
            buyBtn:SetEnable(0);
            local cancelBtn = GET_CHILD_RECURSIVELY(ctrlSet, "cancelBtn");
            cancelBtn:ShowWindow(1)
            cancelBtn:SetEnable(0)

            if USE_MARKET_REPORT == 1 then
                local reportBtn = ctrlSet:GetChild("reportBtn");
                reportBtn:SetEnable(0);
            end

            local totalPrice_num = ctrlSet:GetChild("totalPrice_num");
            totalPrice_num:SetTextByKey("value", 0);
            local totalPrice_text = ctrlSet:GetChild("totalPrice_text");
            totalPrice_text:SetTextByKey("value", 0);
        else

            local buyBtn = GET_CHILD_RECURSIVELY(ctrlSet, "buyBtn");
            buyBtn:ShowWindow(1)
            buyBtn:SetEnable(1);
            local cancelBtn = GET_CHILD_RECURSIVELY(ctrlSet, "cancelBtn");
            cancelBtn:ShowWindow(0)
            cancelBtn:SetEnable(0)

            local editCount = GET_CHILD_RECURSIVELY(ctrlSet, "count")
            editCount:SetMinNumber(1)
            editCount:SetMaxNumber(marketItem.count)
            editCount:SetText("1")
            editCount:SetNumChangeScp("MARKET_CHANGE_COUNT");
            ctrlSet:SetUserValue("minItemCount", 1)
            ctrlSet:SetUserValue("maxItemCount", marketItem.count)

            MARKET_CTRLSET_SET_TOTAL_PRICE(ctrlSet, marketItem);
        end
    end

    local ITEM_CTRLSET_INTERVAL_Y_MARGIN = tonumber(frame:GetUserConfig('ITEM_CTRLSET_INTERVAL_Y_MARGIN'));
    GBOX_AUTO_ALIGN(itemlist, 4, ITEM_CTRLSET_INTERVAL_Y_MARGIN, 0, true, false);

    local category, _category, _subCategory = GET_CATEGORY_STRING(frame);
    local itemCntPerPage = GET_MARKET_SEARCH_ITEM_COUNT(_category);
    local maxPage_recipe = math.ceil(session.market.GetTotalCount() / itemCntPerPage);
    local curPage_recipe = session.market.GetCurPage();
    local pagecontrol_recipe = GET_CHILD(frame, 'pagecontrol_recipe', 'ui::CPageController')
    if maxPage_recipe < 1 then
        maxPage_recipe = 1;
    end

    pagecontrol_recipe:SetMaxPage(maxPage_recipe);
    pagecontrol_recipe:SetCurPage(curPage_recipe);

    local maxPage_material = math.ceil(session.market.GetRecipeSearchCount() /
                                           GET_MARKET_SEARCH_ITEM_COUNT('RecipeMaterial'));
    local curPage_material = session.market.GetRecipeSearchPage();

    local pagecontrol_material = GET_CHILD(frame, 'pagecontrol_material', 'ui::CPageController')
    pagecontrol_material:ShowWindow(1)
    if maxPage_material < 1 then
        maxPage_material = 1;
    end

    pagecontrol_material:SetMaxPage(maxPage_material);
    pagecontrol_material:SetCurPage(curPage_material);
end

function MARKET_DRAW_CTRLSET_ACCESSORY(frame)
    local itemlist = GET_CHILD_RECURSIVELY(frame, "itemListGbox");
    itemlist:RemoveAllChild();
    local mySession = session.GetMySession();
    local cid = mySession:GetCID();
    local count = session.market.GetItemCount();

    MARKET_SELECT_SHOW_TITLE(frame, "accessoryTitle")

    local yPos = 0
    for i = 0, count - 1 do
        local marketItem = session.market.GetItemByIndex(i);
        local itemObj = GetIES(marketItem:GetObject());
        local refreshScp = itemObj.RefreshScp;
        if refreshScp ~= "None" then
            refreshScp = _G[refreshScp];
            refreshScp(itemObj);
        end

        local ctrlSet = itemlist:CreateControlSet("market_item_detail_accessory", "ITEM_EQUIP_" .. i, ui.LEFT, ui.TOP,
                                                  0, 0, 0, yPos);
        AUTO_CAST(ctrlSet)
        ctrlSet:SetUserValue("DETAIL_ROW", i);

        MARKET_CTRLSET_SET_ICON(ctrlSet, itemObj, marketItem);

        local name = ctrlSet:GetChild("name");
        name:SetTextByKey("value", GET_FULL_NAME(itemObj));

        local enchantOption = ""
        local strInfo = ""
        for j = 1, 3 do
            local propName = "HatPropName_" .. j;
            local propValue = "HatPropValue_" .. j;
            if itemObj[propValue] ~= 0 and itemObj[propName] ~= "None" then
                enchantOption = ScpArgMsg(itemObj[propName]);

                if string.find(itemObj[propName], 'ALLSKILL_') ~= nil then
                    local job = StringSplit(itemObj[propName], '_')[2]
                    if job == 'ShadowMancer' then
                        job = 'Shadowmancer'
                    end
                    enchantOption = ScpArgMsg(job) .. ' ' .. ScpArgMsg('skill_lv_up_by_count')
                end

                if j == 1 then
                    strInfo = strInfo .. ABILITY_DESC_PLUS(enchantOption, itemObj[propValue]);
                else
                    strInfo = strInfo .. "{nl} " .. ABILITY_DESC_PLUS(enchantOption, itemObj[propValue]);
                end
            end
        end

        local enchantText = GET_CHILD_RECURSIVELY(ctrlSet, "enchant")
        enchantText:SetTextByKey("value", strInfo)

        if cid == marketItem:GetSellerCID() then
            local buyBtn = GET_CHILD_RECURSIVELY(ctrlSet, "buyBtn");
            buyBtn:ShowWindow(0)
            buyBtn:SetEnable(0);
            local cancelBtn = GET_CHILD_RECURSIVELY(ctrlSet, "cancelBtn");
            cancelBtn:ShowWindow(1)
            cancelBtn:SetEnable(1)

            if USE_MARKET_REPORT == 1 then
                local reportBtn = ctrlSet:GetChild("reportBtn");
                reportBtn:SetEnable(0);
            end

            local totalPrice_num = ctrlSet:GetChild("totalPrice_num");
            totalPrice_num:SetTextByKey("value", 0);
            local totalPrice_text = ctrlSet:GetChild("totalPrice_text");
            totalPrice_text:SetTextByKey("value", 0);
        else

            local buyBtn = GET_CHILD_RECURSIVELY(ctrlSet, "buyBtn");
            buyBtn:ShowWindow(1)
            buyBtn:SetEnable(1);
            local cancelBtn = GET_CHILD_RECURSIVELY(ctrlSet, "cancelBtn");
            cancelBtn:ShowWindow(0)
            cancelBtn:SetEnable(0)

            MARKET_CTRLSET_SET_TOTAL_PRICE(ctrlSet, marketItem);
        end

        ctrlSet:SetUserValue("sellPrice", marketItem:GetSellPrice());
    end

    local ITEM_CTRLSET_INTERVAL_Y_MARGIN = tonumber(frame:GetUserConfig('ITEM_CTRLSET_INTERVAL_Y_MARGIN'));
    GBOX_AUTO_ALIGN(itemlist, 4, ITEM_CTRLSET_INTERVAL_Y_MARGIN, 0, false, true);

    MARKET_SET_PAGE_CONTROL(frame, "pagecontrol")
end

function MARKET_DRAW_CTRLSET_GEM(frame)
    local itemlist = GET_CHILD_RECURSIVELY(frame, "itemListGbox");
    itemlist:RemoveAllChild();
    local mySession = session.GetMySession();
    local cid = mySession:GetCID();
    local count = session.market.GetItemCount();

    MARKET_SELECT_SHOW_TITLE(frame, "gemTitle")

    local yPos = 0
    for i = 0, count - 1 do
        local marketItem = session.market.GetItemByIndex(i);
        local itemObj = GetIES(marketItem:GetObject());
        local refreshScp = itemObj.RefreshScp;
        if refreshScp ~= "None" then
            refreshScp = _G[refreshScp];
            refreshScp(itemObj);
        end

        local ctrlSet = itemlist:CreateControlSet("market_item_detail_gem", "ITEM_EQUIP_" .. i, ui.LEFT, ui.TOP, 0, 0,
                                                  0, yPos);
        AUTO_CAST(ctrlSet)
        ctrlSet:SetUserValue("DETAIL_ROW", i);

        MARKET_CTRLSET_SET_ICON(ctrlSet, itemObj, marketItem);

        local name = ctrlSet:GetChild("name");
        name:SetTextByKey("value", GET_FULL_NAME(itemObj));

        local gemLevel = GET_CHILD_RECURSIVELY(ctrlSet, "gemLevel")
        local gemLevelValue = GET_ITEM_LEVEL_EXP(itemObj)
        gemLevel:SetTextByKey("value", gemLevelValue)

        local gemRoastingLevel = TryGetProp(itemObj, 'GemRoastingLv', 0);
        local roastingLevel = GET_CHILD_RECURSIVELY(ctrlSet, "roastingLevel")
        roastingLevel:SetTextByKey("value", gemRoastingLevel)

        if cid == marketItem:GetSellerCID() then
            local buyBtn = GET_CHILD_RECURSIVELY(ctrlSet, "buyBtn");
            buyBtn:ShowWindow(0)
            buyBtn:SetEnable(0);
            local cancelBtn = GET_CHILD_RECURSIVELY(ctrlSet, "cancelBtn");
            cancelBtn:ShowWindow(1)
            cancelBtn:SetEnable(1)

            if USE_MARKET_REPORT == 1 then
                local reportBtn = ctrlSet:GetChild("reportBtn");
                reportBtn:SetEnable(0);
            end

            local totalPrice_num = ctrlSet:GetChild("totalPrice_num");
            totalPrice_num:SetTextByKey("value", 0);
            local totalPrice_text = ctrlSet:GetChild("totalPrice_text");
            totalPrice_text:SetTextByKey("value", 0);
        else
            local buyBtn = GET_CHILD_RECURSIVELY(ctrlSet, "buyBtn");
            buyBtn:ShowWindow(1)
            buyBtn:SetEnable(1);
            local cancelBtn = GET_CHILD_RECURSIVELY(ctrlSet, "cancelBtn");
            cancelBtn:ShowWindow(0)
            cancelBtn:SetEnable(0)
            MARKET_CTRLSET_SET_TOTAL_PRICE(ctrlSet, marketItem);
        end

        local propNameList = GET_ITEM_PROP_NAME_LIST(itemObj)
        for j = 1, #propNameList do
            local title = propNameList[j]["Title"];
            local propName = propNameList[j]["PropName"];
            local propValue = propNameList[j]["PropValue"];
            local useOperator = propNameList[j]["UseOperator"];
            local propOptDesc = propNameList[j]["OptDesc"];
            if title == nil and TryGetProp(itemObj, "StringArg", "None") ~= "SkillGem" then
                local realtext = nil
                if propName == "CoolDown" then
                    propValue = propValue / 1000;
                    realtext = ScpArgMsg("CoolDown : {Sec} Sec", "Sec", propValue);
                elseif propName == "OptDesc" then
                    realtext = propOptDesc;
                else
                    if useOperator ~= nil and propValue > 0 then
                        realtext = ScpArgMsg(propName) .. " : " .. "{img green_up_arrow 16 16}" .. propValue;
                    else
                        realtext = ScpArgMsg(propName) .. " : " .. "{img red_down_arrow 16 16}" .. propValue;
                    end
                end

                if propName == "OptDesc" then
                    realtext = propOptDesc;
                end

                if realtext ~= nil then
                    SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, realtext);
                end
            end
        end

        for j = 1, MAX_RANDOM_OPTION_COUNT do
            local propGroupName = "RandomOptionGroup_" .. j;
            local propName = "RandomOption_" .. j;
            local propValue = "RandomOptionValue_" .. j;
            local clientMessage = 'None';
            local propItem = itemObj;
            local group = TryGetProp(propItem, "GroupName", "None");
            if group == "Gem" then
                if propItem[propGroupName] == 'ATK' then
                    clientMessage = 'ItemRandomOptionGroupATK'
                elseif propItem[propGroupName] == 'DEF' then
                    clientMessage = 'ItemRandomOptionGroupDEF'
                elseif propItem[propGroupName] == 'UTIL_WEAPON' then
                    clientMessage = 'ItemRandomOptionGroupUTIL'
                elseif propItem[propGroupName] == 'UTIL_ARMOR' then
                    clientMessage = 'ItemRandomOptionGroupUTIL'
                elseif propItem[propGroupName] == 'UTIL_SHILED' then
                    clientMessage = 'ItemRandomOptionGroupUTIL'
                elseif propItem[propGroupName] == 'STAT' then
                    clientMessage = 'ItemRandomOptionGroupSTAT'
                elseif propItem[propGroupName] == 'SPECIAL' then
                    clientMessage = 'ItemRandomOptionGroupSPECIAL'
                end
                if propItem[propValue] ~= 0 and propItem[propName] ~= "None" then
                    local opName = string.format("%s %s", ClMsg(clientMessage), ScpArgMsg(propItem[propName]));
                    if propItem[propValue] ~= nil then
                        local strInfo = ABILITY_DESC_NO_PLUS(opName, propItem[propValue], 0);
                        SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                    end
                end
            end
        end
        ctrlSet:SetUserValue("sellPrice", marketItem:GetSellPrice());
    end
    local ITEM_CTRLSET_INTERVAL_Y_MARGIN = tonumber(frame:GetUserConfig('ITEM_CTRLSET_INTERVAL_Y_MARGIN'));
    GBOX_AUTO_ALIGN(itemlist, 4, ITEM_CTRLSET_INTERVAL_Y_MARGIN, 0, false, true);
    MARKET_SET_PAGE_CONTROL(frame, "pagecontrol")
end

function MARKET_DRAW_CTRLSET_CARD(frame)
    local itemlist = GET_CHILD_RECURSIVELY(frame, "itemListGbox");
    itemlist:RemoveAllChild();
    local mySession = session.GetMySession();
    local cid = mySession:GetCID();
    local count = session.market.GetItemCount();

    MARKET_SELECT_SHOW_TITLE(frame, "cardTitle")

    local yPos = 0
    for i = 0, count - 1 do
        local marketItem = session.market.GetItemByIndex(i);
        local itemObj = GetIES(marketItem:GetObject());
        local refreshScp = itemObj.RefreshScp;
        if refreshScp ~= "None" then
            refreshScp = _G[refreshScp];
            refreshScp(itemObj);
        end

        local ctrlSet = itemlist:CreateControlSet("market_item_detail_card", "ITEM_EQUIP_" .. i, ui.LEFT, ui.TOP, 0, 0,
                                                  0, yPos);
        AUTO_CAST(ctrlSet)
        ctrlSet:SetUserValue("DETAIL_ROW", i);

        MARKET_CTRLSET_SET_ICON(ctrlSet, itemObj, marketItem);

        local name = ctrlSet:GetChild("name");
        name:SetTextByKey("value", GET_FULL_NAME(itemObj));

        local lvText = itemObj.Level;
        if itemObj.GroupName ~= 'Card' then
            lvText = '';
        end
        local level = GET_CHILD_RECURSIVELY(ctrlSet, "level")
        level:SetTextByKey("value", lvText);

        local option = GET_CHILD_RECURSIVELY(ctrlSet, "option")

        local tempText1 = itemObj.Desc;
        if itemObj.Desc == "None" or itemObj.GroupName ~= 'Card' then
            tempText1 = "";
        end

        local textDesc = string.format("%s", tempText1)
        option:SetTextByKey("value", textDesc);

        if cid == marketItem:GetSellerCID() then
            local buyBtn = GET_CHILD_RECURSIVELY(ctrlSet, "buyBtn");
            buyBtn:ShowWindow(0)
            buyBtn:SetEnable(0);
            local cancelBtn = GET_CHILD_RECURSIVELY(ctrlSet, "cancelBtn");
            cancelBtn:ShowWindow(1)
            cancelBtn:SetEnable(1)

            if USE_MARKET_REPORT == 1 then
                local reportBtn = ctrlSet:GetChild("reportBtn");
                reportBtn:SetEnable(0);
            end

            local totalPrice_num = ctrlSet:GetChild("totalPrice_num");
            totalPrice_num:SetTextByKey("value", 0);
            local totalPrice_text = ctrlSet:GetChild("totalPrice_text");
            totalPrice_text:SetTextByKey("value", 0);
        else

            local buyBtn = GET_CHILD_RECURSIVELY(ctrlSet, "buyBtn");
            buyBtn:ShowWindow(1)
            buyBtn:SetEnable(1);
            local cancelBtn = GET_CHILD_RECURSIVELY(ctrlSet, "cancelBtn");
            cancelBtn:ShowWindow(0)
            cancelBtn:SetEnable(0)

            MARKET_CTRLSET_SET_TOTAL_PRICE(ctrlSet, marketItem);
        end

        ctrlSet:SetUserValue("sellPrice", marketItem:GetSellPrice());
    end

    local ITEM_CTRLSET_INTERVAL_Y_MARGIN = tonumber(frame:GetUserConfig('ITEM_CTRLSET_INTERVAL_Y_MARGIN'));
    GBOX_AUTO_ALIGN(itemlist, 4, ITEM_CTRLSET_INTERVAL_Y_MARGIN, 0, false, true);

    MARKET_SET_PAGE_CONTROL(frame, "pagecontrol")
end

function MARKET_DRAW_CTRLSET_EXPORB(frame)
    local itemlist = GET_CHILD_RECURSIVELY(frame, "itemListGbox");
    itemlist:RemoveAllChild();
    local mySession = session.GetMySession();
    local cid = mySession:GetCID();
    local count = session.market.GetItemCount();

    MARKET_SELECT_SHOW_TITLE(frame, "exporbTitle")

    local yPos = 0
    for i = 0, count - 1 do
        local marketItem = session.market.GetItemByIndex(i);
        local itemObj = GetIES(marketItem:GetObject());
        local refreshScp = itemObj.RefreshScp;
        if refreshScp ~= "None" then
            refreshScp = _G[refreshScp];
            refreshScp(itemObj);
        end

        local ctrlSet = itemlist:CreateControlSet("market_item_detail_exporb", "ITEM_EQUIP_" .. i, ui.LEFT, ui.TOP, 0,
                                                  0, 0, yPos);
        AUTO_CAST(ctrlSet)
        ctrlSet:SetUserValue("DETAIL_ROW", i);

        MARKET_CTRLSET_SET_ICON(ctrlSet, itemObj, marketItem);

        local name = ctrlSet:GetChild("name");
        name:SetTextByKey("value", GET_FULL_NAME(itemObj));

        local curExp, maxExp = GET_LEGENDEXPPOTION_EXP(itemObj)
        local expPoint = 0
        if maxExp ~= nil and maxExp ~= 0 then
            expPoint = curExp / maxExp * 100
        else
            expPoint = 0
        end
        local expStr = string.format("%.2f", expPoint)

        MARKET_SET_EXPORB_ICON(ctrlSet, curExp, maxExp, itemObj)

        local exp = GET_CHILD_RECURSIVELY(ctrlSet, "exp")
        exp:SetTextByKey("value", expStr .. "%")

        if cid == marketItem:GetSellerCID() then
            local buyBtn = GET_CHILD_RECURSIVELY(ctrlSet, "buyBtn");
            buyBtn:ShowWindow(0)
            buyBtn:SetEnable(0);
            local cancelBtn = GET_CHILD_RECURSIVELY(ctrlSet, "cancelBtn");
            cancelBtn:ShowWindow(1)
            cancelBtn:SetEnable(1)

            if USE_MARKET_REPORT == 1 then
                local reportBtn = ctrlSet:GetChild("reportBtn");
                reportBtn:SetEnable(0);
            end

            local totalPrice_num = ctrlSet:GetChild("totalPrice_num");
            totalPrice_num:SetTextByKey("value", 0);
            local totalPrice_text = ctrlSet:GetChild("totalPrice_text");
            totalPrice_text:SetTextByKey("value", 0);
        else

            local buyBtn = GET_CHILD_RECURSIVELY(ctrlSet, "buyBtn");
            buyBtn:ShowWindow(1)
            buyBtn:SetEnable(1);
            local cancelBtn = GET_CHILD_RECURSIVELY(ctrlSet, "cancelBtn");
            cancelBtn:ShowWindow(0)
            cancelBtn:SetEnable(0)

            MARKET_CTRLSET_SET_TOTAL_PRICE(ctrlSet, marketItem);
        end

        ctrlSet:SetUserValue("sellPrice", marketItem:GetSellPrice());
    end

    local ITEM_CTRLSET_INTERVAL_Y_MARGIN = tonumber(frame:GetUserConfig('ITEM_CTRLSET_INTERVAL_Y_MARGIN'));
    GBOX_AUTO_ALIGN(itemlist, 4, ITEM_CTRLSET_INTERVAL_Y_MARGIN, 0, false, true);

    MARKET_SET_PAGE_CONTROL(frame, "pagecontrol")
end

function MARKET_DRAW_CTRLSET_OPTMISC(frame)
    local itemlist = GET_CHILD_RECURSIVELY(frame, "itemListGbox");
    itemlist:RemoveAllChild();
    local mySession = session.GetMySession();
    local cid = mySession:GetCID();
    local count = session.market.GetItemCount();

    MARKET_SELECT_SHOW_TITLE(frame, "OPTMiscTitle")

    local yPos = 0
    for i = 0, count - 1 do
        local marketItem = session.market.GetItemByIndex(i);
        local itemObj = GetIES(marketItem:GetObject());
        local refreshScp = itemObj.RefreshScp;
        if refreshScp ~= "None" then
            refreshScp = _G[refreshScp];
            refreshScp(itemObj);
        end

        local ctrlSet = itemlist:CreateControlSet("market_item_detail_OPTMisc", "ITEM_EQUIP_" .. i, ui.LEFT, ui.TOP, 0,
                                                  0, 0, yPos);
        AUTO_CAST(ctrlSet)
        ctrlSet:SetUserValue("DETAIL_ROW", i);
        ctrlSet:SetUserValue("optionIndex", 0)

        local type = GET_CHILD_RECURSIVELY(ctrlSet, "type");
        type:ShowWindow(0);

        local inheritanceItem = GetClass('Item', itemObj.InheritanceItemName)
        if inheritanceItem == nil then
            inheritanceItem = GetClass('Item', itemObj.InheritanceRandomItemName)
        end

        MARKET_CTRLSET_SET_ICON(ctrlSet, itemObj, marketItem);

        local name = GET_CHILD_RECURSIVELY(ctrlSet, "name");
        name:SetTextByKey("value", GET_FULL_NAME(itemObj));

        -- OPTION (아이커)
        local originalItemObj = itemObj
        if inheritanceItem ~= nil then
            itemObj = inheritanceItem

            type:SetTextByKey("value", ClMsg(inheritanceItem.ClassType));
            type:ShowWindow(1);

            if needAppraisal == 1 or needRandomOption == 1 then
                SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, '{@st66b}' .. ScpArgMsg("AppraisalItem"))
            end

            local basicList = GET_EQUIP_TOOLTIP_PROP_LIST(itemObj);
            local list = {};
            local basicTooltipPropList = StringSplit(itemObj.BasicTooltipProp, ';');
            for i = 1, #basicTooltipPropList do
                local basicTooltipProp = basicTooltipPropList[i];
                list = GET_CHECK_OVERLAP_EQUIPPROP_LIST(basicList, basicTooltipProp, list);
            end

            local list2 = GET_EUQIPITEM_PROP_LIST();
            local cnt = 0;
            local class = GetClassByType("Item", itemObj.ClassID);

            local maxRandomOptionCnt = MAX_OPTION_EXTRACT_COUNT;
            local randomOptionProp = {};
            for i = 1, maxRandomOptionCnt do
                if itemObj['RandomOption_' .. i] ~= 'None' then
                    randomOptionProp[itemObj['RandomOption_' .. i]] = itemObj['RandomOptionValue_' .. i];
                end
            end

            for i = 1, #list do
                local propName = list[i];
                local propValue = TryGetProp(class, propName, 0);

                local needToShow = true;
                for j = 1, #basicTooltipPropList do
                    if basicTooltipPropList[j] == propName then
                        needToShow = false;
                    end
                end

                if needToShow == true and propValue ~= 0 and randomOptionProp[propName] == nil then -- 랜덤 옵션이랑 겹치는 프로퍼티는 여기서 출력하지 않음
                    if itemObj.GroupName == 'Weapon' then
                        if propName ~= "MINATK" and propName ~= 'MAXATK' then
                            local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), propValue);
                            SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                        end
                    elseif itemObj.GroupName == 'Armor' then
                        if itemObj.ClassType == 'Gloves' then
                            if propName ~= "HR" then
                                local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), propValue);
                                SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                            end
                        elseif itemObj.ClassType == 'Boots' then
                            if propName ~= "DR" then
                                local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), propValue);
                                SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                            end
                        else
                            if propName ~= "DEF" then
                                local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), propValue);
                                SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                            end
                        end
                    else
                        local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), propValue);
                        SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                    end
                end
            end

            for i = 1, 3 do
                local propName = "HatPropName_" .. i;
                local propValue = "HatPropValue_" .. i;
                if itemObj[propValue] ~= 0 and itemObj[propName] ~= "None" then
                    local opName
                    if string.find(itemObj[propName], 'ALLSKILL_') == nil then
                        opName = string.format("[%s] %s", ClMsg("EnchantOption"), ScpArgMsg(itemObj[propName]));
                    else
                        local job = StringSplit(itemObj[propName], '_')[2]
                        if job == 'ShadowMancer' then
                            job = 'Shadowmancer'
                        end
                        opName = string.format("[%s] %s", ClMsg("EnchantOption"),
                                               ScpArgMsg(job) .. ' ' .. ScpArgMsg('skill_lv_up_by_count'));
                    end
                    local strInfo = ABILITY_DESC_PLUS(opName, itemObj[propValue]);
                    SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                end
            end

            for i = 1, maxRandomOptionCnt do
                local propGroupName = "RandomOptionGroup_" .. i;
                local propName = "RandomOption_" .. i;
                local propValue = "RandomOptionValue_" .. i;
                local clientMessage = 'None'

                local propItem = originalItemObj

                if propItem[propGroupName] == 'ATK' then
                    clientMessage = 'ItemRandomOptionGroupATK'
                elseif propItem[propGroupName] == 'DEF' then
                    clientMessage = 'ItemRandomOptionGroupDEF'
                elseif propItem[propGroupName] == 'UTIL_WEAPON' then
                    clientMessage = 'ItemRandomOptionGroupUTIL'
                elseif propItem[propGroupName] == 'UTIL_ARMOR' then
                    clientMessage = 'ItemRandomOptionGroupUTIL'
                elseif propItem[propGroupName] == 'UTIL_SHILED' then
                    clientMessage = 'ItemRandomOptionGroupUTIL'
                elseif propItem[propGroupName] == 'STAT' then
                    clientMessage = 'ItemRandomOptionGroupSTAT'
                elseif propItem[propGroupName] == 'SPECIAL' then
                    clientMessage = 'ItemRandomOptionGroupSPECIAL'
                end

                if propItem[propValue] ~= 0 and propItem[propName] ~= "None" then
                    local opName = string.format("%s %s", ClMsg(clientMessage), ScpArgMsg(propItem[propName]));
                    local strInfo = ABILITY_DESC_NO_PLUS(opName, propItem[propValue], 0);
                    SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                end
            end

            _CREATE_SEAL_OPTION(ctrlSet, itemObj);

            for i = 1, #list2 do
                local propName = list2[i];
                local propValue = TryGetProp(itemObj, propName, 0);
                if propValue ~= 0 then
                    local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), propValue);
                    SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                end
            end

            if itemObj.OptDesc ~= nil and itemObj.OptDesc ~= 'None' then
                SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, itemObj.OptDesc);
            end

            if originalItemObj['RandomOptionRareValue'] ~= 0 and originalItemObj['RandomOptionRare'] ~= "None" then
                local strInfo = _GET_RANDOM_OPTION_RARE_CLIENT_TEXT(originalItemObj['RandomOptionRare'],
                                                                    originalItemObj['RandomOptionRareValue'], '');
                if strInfo ~= nil then
                    SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                end
            end

            if inheritanceItem == nil then
                if itemObj.IsAwaken == 1 then
                    local opName = string.format("[%s] %s", ClMsg("AwakenOption"), ScpArgMsg(itemObj.HiddenProp));
                    local strInfo = ABILITY_DESC_PLUS(opName, itemObj.HiddenPropValue);
                    SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                end
            else
                if inheritanceItem.IsAwaken == 1 then
                    local opName =
                        string.format("[%s] %s", ClMsg("AwakenOption"), ScpArgMsg(inheritanceItem.HiddenProp));
                    local strInfo = ABILITY_DESC_PLUS(opName, inheritanceItem.HiddenPropValue);
                    SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                end
            end

            if itemObj.ReinforceRatio > 100 then
                local opName = ClMsg("ReinforceOption");
                local strInfo = ABILITY_DESC_PLUS(opName, math.floor(10 * itemObj.ReinforceRatio / 100));
                SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
            end

        end

        local goddessIcor = string.find(itemObj.StringArg, "GoddessIcor")
        if goddessIcor ~= nil then
            local maxRandomOptionCnt = MAX_OPTION_EXTRACT_COUNT;
            local randomOptionProp = {};
            for i = 1, maxRandomOptionCnt do
                if itemObj['RandomOption_' .. i] ~= 'None' then
                    randomOptionProp[itemObj['RandomOption_' .. i]] = itemObj['RandomOptionValue_' .. i];
                end
            end

            for i = 1, maxRandomOptionCnt do
                local propGroupName = "RandomOptionGroup_" .. i;
                local propName = "RandomOption_" .. i;
                local propValue = "RandomOptionValue_" .. i;
                local clientMessage = 'None'

                local propItem = originalItemObj

                if propItem[propGroupName] == 'ATK' then
                    clientMessage = 'ItemRandomOptionGroupATK'
                elseif propItem[propGroupName] == 'DEF' then
                    clientMessage = 'ItemRandomOptionGroupDEF'
                elseif propItem[propGroupName] == 'UTIL_WEAPON' then
                    clientMessage = 'ItemRandomOptionGroupUTIL'
                elseif propItem[propGroupName] == 'UTIL_ARMOR' then
                    clientMessage = 'ItemRandomOptionGroupUTIL'
                elseif propItem[propGroupName] == 'UTIL_SHILED' then
                    clientMessage = 'ItemRandomOptionGroupUTIL'
                elseif propItem[propGroupName] == 'STAT' then
                    clientMessage = 'ItemRandomOptionGroupSTAT'
                elseif propItem[propGroupName] == 'SPECIAL' then
                    clientMessage = 'ItemRandomOptionGroupSPECIAL'
                end

                if propItem[propValue] ~= 0 and propItem[propName] ~= "None" then
                    local opName = string.format("%s %s", ClMsg(clientMessage), ScpArgMsg(propItem[propName]));
                    local strInfo = ABILITY_DESC_NO_PLUS(opName, propItem[propValue], 0);
                    SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                end
            end
        end

        -- 내 판매리스트 처리
        if cid == marketItem:GetSellerCID() then
            local buyBtn = GET_CHILD_RECURSIVELY(ctrlSet, "buyBtn");
            buyBtn:ShowWindow(0)
            buyBtn:SetEnable(0);
            local cancelBtn = GET_CHILD_RECURSIVELY(ctrlSet, "cancelBtn");
            cancelBtn:ShowWindow(1)
            cancelBtn:SetEnable(1)

            if USE_MARKET_REPORT == 1 then
                local reportBtn = GET_CHILD_RECURSIVELY(ctrlSet, "reportBtn");
                reportBtn:SetEnable(0);
            end

            local totalPrice_num = GET_CHILD_RECURSIVELY(ctrlSet, "totalPrice_num");
            totalPrice_num:SetTextByKey("value", 0);
            local totalPrice_text = GET_CHILD_RECURSIVELY(ctrlSet, "totalPrice_text");
            totalPrice_text:SetTextByKey("value", 0);
        else

            local buyBtn = GET_CHILD_RECURSIVELY(ctrlSet, "buyBtn");
            buyBtn:ShowWindow(1)
            buyBtn:SetEnable(1);
            local cancelBtn = GET_CHILD_RECURSIVELY(ctrlSet, "cancelBtn");
            cancelBtn:ShowWindow(0)
            cancelBtn:SetEnable(0)

            MARKET_CTRLSET_SET_TOTAL_PRICE(ctrlSet, marketItem);
        end

        ctrlSet:SetUserValue("sellPrice", marketItem:GetSellPrice());
    end

    local ITEM_CTRLSET_INTERVAL_Y_MARGIN = tonumber(frame:GetUserConfig('ITEM_CTRLSET_INTERVAL_Y_MARGIN'));
    GBOX_AUTO_ALIGN(itemlist, 4, ITEM_CTRLSET_INTERVAL_Y_MARGIN, 0, true, false);

    MARKET_SET_PAGE_CONTROL(frame, "pagecontrol")
end

function MARKET_SET_EXPORB_ICON(ctrlSet, curExp, maxExp, itemObj)
    local pic = GET_CHILD_RECURSIVELY(ctrlSet, "pic");
    if curExp == maxExp then
        local fullImage = GET_LEGENDEXPPOTION_ICON_IMAGE_FULL(itemObj);
        local icon = pic:GetIcon()
        if icon ~= nil then
            icon:SetImage(fullImage)
        end
    end
end

function MARKET_SELECT_SHOW_TITLE(frame, titleName)
    frame = ui.GetFrame("market")
    if titleName == nil or titleName == "" then
        return
    end

    for i = 1, #g_titleGboxList do
        local visible = 0
        local tempTitle = g_titleGboxList[i]
        if titleName == tempTitle then
            visible = 1
        end
        local tempTitleGbox = GET_CHILD_RECURSIVELY(frame, tempTitle)
        if tempTitleGbox ~= nil then
            tempTitleGbox:ShowWindow(visible)
        end
    end

end

function CANCEL_MARKET_ITEM(parent, ctrl)
    local row = parent:GetUserIValue("DETAIL_ROW");
    local marketItem = session.market.GetItemByIndex(row);
    local itemObj = GetIES(marketItem:GetObject());
    local guid = marketItem:GetMarketGuid()

    local yesScp = string.format("EXEC_CANCEL_MARKET_ITEM(\"%s\")", guid);
    local msgbox = ui.MsgBox_NonNested(ClMsg("ReallyCancelRegisteredItem"), 'market', yesScp, "None");
    SET_MODAL_MSGBOX(msgbox);
end

function EXEC_CANCEL_MARKET_ITEM(itemGuid)
    market.CancelMarketItem(itemGuid);
end

function MARKET_SET_TOTAL_PRICE(ctrlset, price, count)
    local totalPrice_num = GET_CHILD_RECURSIVELY(ctrlset, "totalPrice_num")
    local a, b, c = math.mul_int_for_lua(price, count)
    totalPrice_num:SetTextByKey("value", GET_COMMAED_STRING(tonumber(a)))
    local totalPrice_text = GET_CHILD_RECURSIVELY(ctrlset, "totalPrice_text")
    totalPrice_text:SetTextByKey("value", GetMonetaryString(tonumber(a)))
end

function MARKET_CHANGE_COUNT(parent, ctrl)
    local ctrlset = parent;
    if parent:GetName() == "count" then
        ctrlset = parent:GetParent()
    end

    local priceFrame = GET_CHILD_RECURSIVELY(ctrlset, "price_num");
    local editCount = GET_CHILD_RECURSIVELY(ctrlset, "count");
    local price = priceFrame:GetUserValue("Price");

    MARKET_SET_TOTAL_PRICE(ctrlset, price, editCount:GetNumber())
end

function MARKET_ITEM_COUNT_UP(frame)
    local editCount = GET_CHILD_RECURSIVELY(frame, "count")
    if editCount == nil then
        return
    end

    local nowCount = tonumber(editCount:GetText())
    nowCount = nowCount + 1

    local maxItemCount = frame:GetUserIValue("maxItemCount")

    if nowCount >= maxItemCount then
        nowCount = maxItemCount;
    end

    editCount:SetText(tostring(nowCount))

    local price_num = GET_CHILD_RECURSIVELY(frame, "price_num")
    local price = frame:GetUserValue("sellPrice")

    MARKET_SET_TOTAL_PRICE(frame, price, nowCount)
end

function MARKET_ITEM_COUNT_DOWN(frame)
    local editCount = GET_CHILD_RECURSIVELY(frame, "count")
    if editCount == nil then
        return
    end

    local nowCount = tonumber(editCount:GetText())
    nowCount = nowCount - 1

    local minItemCount = frame:GetUserIValue("minItemCount")

    if nowCount <= minItemCount then
        nowCount = minItemCount;
    end

    editCount:SetText(tostring(nowCount))

    local price_num = GET_CHILD_RECURSIVELY(frame, "price_num")
    local price = frame:GetUserValue("sellPrice")

    MARKET_SET_TOTAL_PRICE(frame, price, nowCount)
end

function MARKET_ITEM_COUNT_MAX(frame)
    local editCount = GET_CHILD_RECURSIVELY(frame, "count")
    if editCount == nil then
        return
    end

    local maxItemCount = frame:GetUserIValue("maxItemCount")
    local price_num = GET_CHILD_RECURSIVELY(frame, "price_num")
    local price = frame:GetUserValue("sellPrice")

    local maxCanBuyCount = math.max(math.floor(tonumber(GET_TOTAL_MONEY_STR()) / price), 1);
    local maxItemCount = math.min(maxItemCount, maxCanBuyCount)
    editCount:SetText(tostring(maxItemCount))

    MARKET_SET_TOTAL_PRICE(frame, price, maxItemCount)
end

function GET_REMAIN_MARKET_TRADE_AMOUNT_STR()
    return SumForBigNumberInt64(session.inventory.GetMarketLimitAmount(), -session.inventory.GetCurMarketTradeAmount());
end

function _BUY_MARKET_ITEM(row, isRecipeSearchBox)
    local frame = ui.GetFrame("market");

    local totalPrice = 0;
    market.ClearBuyInfo();

    if isRecipeSearchBox ~= nil and isRecipeSearchBox == 1 then
        local itemlist = GET_CHILD_RECURSIVELY(frame, "recipeSearchGbox")
        local child = itemlist:GetChildByIndex(row - 1);
        local editCount = GET_CHILD_RECURSIVELY(child, "count")
        if editCount == nil then
            local marketItem = session.market.GetRecipeSearchByIndex(row - 1);
            market.AddBuyInfo(marketItem:GetMarketGuid(), 1);
            totalPrice = SumForBigNumber(totalPrice, marketItem:GetSellPrice());
        else
            local buyCount = editCount:GetText()
            if tonumber(buyCount) > 0 then
                local marketItem = session.market.GetRecipeSearchByIndex(row - 1);
                market.AddBuyInfo(marketItem:GetMarketGuid(), buyCount);
                local a, b, c = math.mul_int_for_lua(buyCount, marketItem:GetSellPrice())
                totalPrice = SumForBigNumber(totalPrice, a);
            else
                ui.SysMsg(ScpArgMsg("YouCantBuyZeroItem"));
            end
        end
    else
        local itemlist = GET_CHILD_RECURSIVELY(frame, "itemListGbox");
        local child = itemlist:GetChildByIndex(row - 1);
        if child == nil then
            local marketItem = session.market.GetItemByIndex(row - 1);
            market.AddBuyInfo(marketItem:GetMarketGuid(), 1);
            totalPrice = SumForBigNumber(totalPrice, marketItem:GetSellPrice());
        else
            local editCount = GET_CHILD_RECURSIVELY(child, "count")
            local buyCount = 1;
            if editCount ~= nil then
                buyCount = editCount:GetText()
            end

            if tonumber(buyCount) > 0 then
                local marketItem = session.market.GetItemByIndex(row - 1);
                market.AddBuyInfo(marketItem:GetMarketGuid(), buyCount);
                local a, b, c = math.mul_int_for_lua(buyCount, marketItem:GetSellPrice())
                totalPrice = SumForBigNumber(totalPrice, a);
            else
                ui.SysMsg(ScpArgMsg("YouCantBuyZeroItem"));
            end
        end
    end

    if totalPrice == 0 then
        return;
    end

    local limitTradeStr = GET_REMAIN_MARKET_TRADE_AMOUNT_STR();
    if limitTradeStr ~= nil then
        if IsGreaterThanForBigNumber(totalPrice, limitTradeStr) == 1 then
            ui.SysMsg(ScpArgMsg('MarketMaxSilverLimit{LIMIT}Over', 'LIMIT', GET_COMMAED_STRING(limitTradeStr)));
            return;
        end
    end

    market.ReqBuyItems();
end

function BUY_MARKET_ITEM(parent, ctrl)
    local frame = ui.GetFrame("market")
    local row = parent:GetUserIValue("DETAIL_ROW");
    local marketGuid = parent:GetUserValue("marketItemGuid")
    local marketRecipeSearchGuid = parent:GetUserValue("marketRecipeSearchGuid")
    local isRecipeSearchBox = 0
    local marketItem = session.market.GetItemByIndex(row);
    if marketRecipeSearchGuid ~= nil and marketRecipeSearchGuid ~= "None" then
        marketItem = session.market.GetRecipeSearchItemByMarketID(marketRecipeSearchGuid)
        isRecipeSearchBox = 1
        frame:SetUserValue("isRecipeSearching", 1)
    else
        frame:SetUserValue("isRecipeSearching", 0)
    end

    local itemObj = GetIES(marketItem:GetObject());
    local remainAmount = GET_REMAIN_MARKET_TRADE_AMOUNT_STR();
    local txt = ScpArgMsg('MarketTradeLimit{AMOUNT}ReallyBuy?', 'AMOUNT', GET_COMMAED_STRING(remainAmount));
    local msgbox = ui.MsgBox_NonNested(txt, 'market',
                                       string.format("_BUY_MARKET_ITEM(%d, %d)", row + 1, isRecipeSearchBox), "None");
    SET_MODAL_MSGBOX(msgbox);
end

function _REPORT_MARKET_ITEM(row)
    if row == nil then
        return
    end

    local marketItem = session.market.GetItemByIndex(row - 1);

    if marketItem == nil then
        return;
    end

    local scpString = string.format("/marketreport %s", marketItem:GetMarketGuid());
    ui.Chat(scpString);
end

function REPORT_MARKET_ITEM(parent, ctrl)
    local row = parent:GetUserIValue("DETAIL_ROW");
    local marketItem = session.market.GetItemByIndex(row);
    local itemObj = GetIES(marketItem:GetObject());
    local txt = ScpArgMsg("ReallyReport");

    local msgbox = ui.MsgBox_NonNested(txt, 'market', string.format("_REPORT_MARKET_ITEM(%d)", row + 1), "None");
    SET_MODAL_MSGBOX(msgbox);
end

function MARKET_SELLMODE(frame)
    frame:SetUserValue("isRecipeSearching", 0)
    ui.CloseFrame("market");
    ui.CloseFrame("market_cabinet");
    ui.OpenFrame("market_sell");
    ui.OpenFrame("inventory");
end

function MARKET_BUYMODE(frame)
    frame:SetUserValue("isRecipeSearching", 0)
    ui.OpenFrame("market");
    ui.CloseFrame("market_sell");
    ui.CloseFrame("market_cabinet");
    MARKET_FIRST_OPEN(ui.GetFrame('market'));
end

function MARKET_CABINET_MODE(frame)
    frame:SetUserValue("isRecipeSearching", 0)
    ui.CloseFrame("market");
    ui.CloseFrame("market_sell");
    ui.OpenFrame("market_cabinet");
end

local marketCategorySortCriteria = { -- 숫자가 작은 순서로 나오고, 없는 애들은 밑에 감
    Weapon = 1,
    Armor = 2,
    Consume = 3,
    Accessory = 4,
    Recipe = 5,
    Card = 6,
    Misc = 7,
    Gem = 8
};

local function SORT_CATEGORY(categoryList, sortFunc)
    table.sort(categoryList, sortFunc);
    return categoryList;
end

function MARKET_INIT_CATEGORY(frame)
    local marketCategory = GET_CHILD_RECURSIVELY(frame, 'marketCategory');
    local bgBox = GET_CHILD(marketCategory, 'bgBox');

    local cateListBox = GET_CHILD_RECURSIVELY(marketCategory, 'cateListBox');
    cateListBox:RemoveAllChild();

    local categoryList = SORT_CATEGORY(GetMarketCategoryList('root'), function(lhs, rhs)
        local lhsValue = marketCategorySortCriteria[lhs];
        local rhsValue = marketCategorySortCriteria[rhs];

        if lhsValue == nil then
            lhsValue = 200000000;
        end
        if rhsValue == nil then
            rhsValue = 200000000;
        end

        return lhsValue < rhsValue;
    end);

    for i = 0, #categoryList do
        local group;
        if i == 0 then
            group = 'IntegrateRetreive';
        else
            group = categoryList[i];
        end
        local ctrlSet = cateListBox:CreateControlSet("market_tree", "CATEGORY_" .. group, ui.LEFT, 0, 0, 0, 0, 0);
        local part = ctrlSet:GetChild("part");
        part:SetTextByKey("value", ClMsg(group));
        ctrlSet:SetUserValue('CATEGORY', group);
    end
    GBOX_AUTO_ALIGN(cateListBox, 0, 0, 0, true, false);

    local optionBox = GET_CHILD_RECURSIVELY(frame, 'optionBox');
    optionBox:ShowWindow(0);

    frame:SetUserValue('SELECTED_CATEGORY', 'None');
    frame:SetUserValue('SELECTED_SUB_CATEGORY', 'None');

    -- 첨 키면 통합 검색 키게 해달라고 하셨다
    local integrateRetreiveCtrlset = GET_CHILD_RECURSIVELY(frame, 'CATEGORY_IntegrateRetreive');
    MARKET_CATEGORY_CLICK(integrateRetreiveCtrlset);
end

function ALIGN_CATEGORY_BOX(cateListBox, selectedCtrlset, subCateBox)
    local ypos = 0;
    local needMove = false;
    local childCnt = cateListBox:GetChildCount();
    for i = 0, childCnt - 1 do
        local child = cateListBox:GetChildByIndex(i);
        if string.find(child:GetName(), 'CATEGORY_') ~= nil then
            child:SetOffset(0, ypos);
            if subCateBox ~= nil and child == selectedCtrlset then
                subCateBox:SetOffset(subCateBox:GetX(), ypos + child:GetHeight());
                ypos = ypos + subCateBox:GetHeight();
                needMove = true;
            end
            ypos = ypos + child:GetHeight();
        end
    end
end

local function ADD_SUB_CATEGORY(detailBox, parentCategory, subCategoryList)
    if #subCategoryList < 1 then
        return 0;
    end

    local frame = detailBox:GetTopParentFrame();
    DESTROY_CHILD_BYNAME(detailBox, 'subCateBox');

    -- sort sub category
    if parentCategory == 'HairAcc' then
        subCategoryList = SORT_CATEGORY(subCategoryList, function(lhs, rhs)
            return lhs < rhs;
        end);
    end

    local subCateBox = detailBox:CreateControl('groupbox', 'subCateBox', 0, 0, detailBox:GetWidth(), 0);
    AUTO_CAST(subCateBox);
    subCateBox:SetSkinName('None');
    subCateBox:EnableScrollBar(0);
    for i = 0, #subCategoryList do
        local category = subCategoryList[i];
        if category == nil then
            category = 'ShowAll';
        end
        if category ~= 'Relic' then
            local subCateCtrlset = subCateBox:CreateControl('groupbox', 'SUB_CATE_' .. category, 0, 0,
                                                            detailBox:GetWidth(), 20);
            AUTO_CAST(subCateCtrlset);
            subCateCtrlset:SetSkinName('None');
            subCateCtrlset:SetUserValue('PARENT_CATEGORY', parentCategory);
            subCateCtrlset:SetUserValue('CATEGORY', category);
            subCateCtrlset:SetEventScript(ui.LBUTTONUP, 'MARKET_SUB_CATEOGRY_CLICK');
            subCateCtrlset:EnableScrollBar(0);

            local text = subCateCtrlset:CreateControl('richtext', 'text', 20, 0, 100, 20);
            text:SetGravity(ui.LEFT, ui.CENTER_VERT);
            text:SetFontName('brown_16_b');
            text:SetText(ClMsg(category));
            text:EnableHitTest(0);
        end
    end

    GBOX_AUTO_ALIGN(subCateBox, 2, 2, 0, true, true);
    detailBox:Resize(detailBox:GetWidth(), subCateBox:GetHeight());
    return subCateBox:GetHeight();
end

local function ADD_LEVEL_RANGE(detailBox, ypos, parentCategory)
    if parentCategory ~= 'Weapon' and parentCategory ~= 'Accessory' and parentCategory ~= 'Armor' and parentCategory ~=
        'Recipe' and parentCategory ~= 'OPTMisc' then
        return ypos;
    end

    local market_level = detailBox:CreateOrGetControlSet('market_level', 'levelRangeSet', 0, ypos);
    local minEdit = GET_CHILD_RECURSIVELY(market_level, 'minEdit');
    local maxEdit = GET_CHILD_RECURSIVELY(market_level, 'maxEdit');
    minEdit:SetText('');
    maxEdit:SetText('');
    ypos = ypos + market_level:GetHeight();
    return ypos;
end

local function ADD_ITEM_GRADE(detailBox, ypos, parentCategory)
    if parentCategory ~= 'Weapon' and parentCategory ~= 'Accessory' and parentCategory ~= 'Armor' and parentCategory ~=
        'Recipe' then
        return ypos;
    end

    local market_grade = detailBox:CreateOrGetControlSet('market_grade', 'gradeCheckSet', 0, ypos);
    ypos = ypos + market_grade:GetHeight();
    return ypos;
end

local function ADD_ITEM_SEARCH(detailBox, ypos, parentCategory)
    local market_search = detailBox:CreateOrGetControlSet('market_search', 'itemSearchSet', 0, ypos);
    ypos = ypos + market_search:GetHeight();
    return ypos;
end

local function ADD_APPRAISAL_OPTION(detailBox, ypos, parentCategory)
    if parentCategory ~= 'Weapon' and parentCategory ~= 'Accessory' and parentCategory ~= 'Armor' then
        return ypos;
    end

    local market_appraisal = detailBox:CreateOrGetControlSet('market_appraisal', 'appCheckSet', 0, ypos);
    ypos = ypos + market_appraisal:GetHeight();
    return ypos;
end

local function ADD_DETAIL_OPTION_SETTING(detailBox, ypos, parentCategory, forceOpen)
    if parentCategory ~= 'Weapon' and parentCategory ~= 'Accessory' and parentCategory ~= 'Armor' and parentCategory ~=
        'Recipe' and parentCategory ~= 'HairAcc' and parentCategory ~= 'OPTMisc' and parentCategory ~= 'Gem' then
        return ypos;
    end

    if parentCategory ~= 'HairAcc' and parentCategory ~= 'Recipe' and parentCategory ~= 'OPTMisc' and parentCategory ~=
        'Gem' then
        local market_detail_setting = detailBox:CreateOrGetControlSet('market_detail_setting', 'detailOptionSet', 0,
                                                                      ypos);
        if forceOpen ~= true then
            MARKET_ADD_SEARCH_DETAIL_SETTING(market_detail_setting, nil, true);
        end
        ypos = ypos + market_detail_setting:GetHeight();
    end

    local market_option_group = detailBox:CreateOrGetControlSet('market_option_group', 'optionGroupSet', 0, ypos);
    if forceOpen ~= true then
        MARKET_ADD_SEARCH_OPTION_GROUP(market_option_group, nil, true);
    end
    ypos = ypos + market_option_group:GetHeight();
    return ypos;
end

local function ADD_SEARCH_COMMIT(detailBox, ypos, parentCategory)
    local market_commit = detailBox:CreateOrGetControlSet('market_commit', 'commitSet', 0, ypos);
    ypos = ypos + market_commit:GetHeight();
    return ypos;
end

local function ADD_GEM_OPTION(detailBox, ypos, parentCategory)
    if parentCategory ~= 'Gem' and parentCategory ~= 'Card' then
        return ypos;
    end

    local market_gem_option = detailBox:CreateOrGetControlSet('market_gem_option', 'gemOptionSet', 0, ypos);
    local levelMinEdit = GET_CHILD_RECURSIVELY(market_gem_option, 'levelMinEdit');
    local levelMaxEdit = GET_CHILD_RECURSIVELY(market_gem_option, 'levelMaxEdit');
    levelMinEdit:SetText('');
    levelMaxEdit:SetText('');

    local roastingMinEdit = GET_CHILD_RECURSIVELY(market_gem_option, 'roastingMinEdit');
    local roastingMaxEdit = GET_CHILD_RECURSIVELY(market_gem_option, 'roastingMaxEdit');
    roastingMinEdit:SetText('');
    roastingMaxEdit:SetText('');

    if parentCategory == 'Card' then
        market_gem_option:Resize(market_gem_option:GetWidth(), 40);
    end
    ypos = ypos + market_gem_option:GetHeight();
    return ypos;
end

function DRAW_DETAIL_CATEGORY(frame, selectedCtrlset, subCategoryList, forceOpen)
    local parentCategory = selectedCtrlset:GetUserValue('CATEGORY');
    local cateListBox = selectedCtrlset:GetParent();
    local detailBox = cateListBox:CreateControl('groupbox', 'detailBox', 5, 0, selectedCtrlset:GetWidth() - 20, 0);
    AUTO_CAST(detailBox);
    detailBox:SetSkinName('None');
    detailBox:EnableScrollBar(0);

    if parentCategory == 'IntegrateRetreive' then
        local _ypos = ADD_ITEM_SEARCH(detailBox, 0, parentCategory);
        _ypos = ADD_SEARCH_COMMIT(detailBox, _ypos, parentCategory);
        detailBox:Resize(detailBox:GetWidth(), _ypos);
        return detailBox;
    end

    local ypos = ADD_SUB_CATEGORY(detailBox, parentCategory, subCategoryList);
    ypos = ADD_LEVEL_RANGE(detailBox, ypos, parentCategory);
    ypos = ADD_ITEM_GRADE(detailBox, ypos, parentCategory);
    ypos = ADD_ITEM_SEARCH(detailBox, ypos, parentCategory);
    ypos = ADD_SEARCH_COMMIT(detailBox, ypos, parentCategory);
    ypos = ADD_APPRAISAL_OPTION(detailBox, ypos, parentCategory);
    ypos = ADD_DETAIL_OPTION_SETTING(detailBox, ypos, parentCategory, forceOpen);
    ypos = ADD_GEM_OPTION(detailBox, ypos, parentCategory);

    detailBox:Resize(detailBox:GetWidth(), ypos);
    return detailBox;
end

function MARKET_CATEGORY_CLICK(ctrlset, ctrl, reqList, forceOpen)
    local frame = ctrlset:GetTopParentFrame();
    frame:SetUserValue('SELECTED_SUB_CATEGORY', 'None');
    MARKET_OPTION_BOX_CLOSE_CLICK(frame);

    local prevSelectCategory = frame:GetUserValue('SELECTED_CATEGORY');
    local category = ctrlset:GetUserValue('CATEGORY');
    local foldimg = GET_CHILD(ctrlset, 'foldimg');
    local cateListBox = GET_CHILD_RECURSIVELY(frame, 'cateListBox');
    DESTROY_CHILD_BYNAME(cateListBox, 'detailBox');

    if forceOpen ~= true and (prevSelectCategory == 'None' or prevSelectCategory == category) then
        if foldimg:GetUserValue('IS_PLUS_IMAGE') == 'YES' then
            foldimg:SetImage('viewunfold');
            foldimg:SetUserValue('IS_PLUS_IMAGE', 'NO');
            ALIGN_CATEGORY_BOX(ctrlset:GetParent(), ctrlset);
            return;
        end
    end
    frame:SetUserValue('isRecipeSearching', 0);

    -- color change
    local prevSelectCtrlset = GET_CHILD_RECURSIVELY(frame, 'CATEGORY_' .. prevSelectCategory);
    if prevSelectCtrlset ~= nil then
        local bgBox = GET_CHILD(prevSelectCtrlset, 'bgBox');
        bgBox:SetSkinName('base_btn');

        local foldimg = GET_CHILD(prevSelectCtrlset, 'foldimg');
        foldimg:SetImage('viewunfold');
        foldimg:SetUserValue('IS_PLUS_IMAGE', 'NO');
        imcSound.PlaySoundEvent('button_click_roll_close');
    end
    local bgBox = GET_CHILD(ctrlset, 'bgBox');
    bgBox:SetSkinName('baseyellow_btn');
    frame:SetUserValue('SELECTED_CATEGORY', category);

    -- fold img
    foldimg:SetImage('spreadclose');
    foldimg:SetUserValue('IS_PLUS_IMAGE', 'YES');

    local subCategoryList = GetMarketCategoryList(category);
    if #subCategoryList > 0 then
        imcSound.PlaySoundEvent("button_click_roll_open");
    else
        imcSound.PlaySoundEvent("button_click_4");
    end
    local detailBox = DRAW_DETAIL_CATEGORY(frame, ctrlset, subCategoryList, forceOpen);
    ALIGN_CATEGORY_BOX(ctrlset:GetParent(), ctrlset, detailBox);

    if reqList ~= false then
        MARKET_REQ_LIST(frame);
    end
end

function MARKET_SUB_CATEOGRY_CLICK(parent, subCategoryCtrlset, reqList)
    local frame = parent:GetTopParentFrame();
    local prevSelectedSubCategory = frame:GetUserValue('SELECTED_SUB_CATEGORY');
    local prevSelectedSubCateCtrlset = GET_CHILD_RECURSIVELY(frame, 'SUB_CATE_' .. prevSelectedSubCategory);
    if prevSelectedSubCateCtrlset ~= nil then
        prevSelectedSubCateCtrlset:FillColor(false, nil);
    end

    local parentCategory = subCategoryCtrlset:GetUserValue('PARENT_CATEGORY');
    local category = subCategoryCtrlset:GetUserValue('CATEGORY');
    subCategoryCtrlset:FillColor(true, 'FFDEDE00');
    frame:SetUserValue('SELECTED_SUB_CATEGORY', category);

    if reqList ~= false then
        MARKET_REQ_LIST(frame);
    end
end

local function CLAMP_MARKET_PAGE_NUMBER(frame, pageControllerName, page)
    if page == nil then
        return 0;
    end
    local pagecontrol = GET_CHILD(frame, pageControllerName);
    local MaxPage = pagecontrol:GetMaxPage();
    if page >= MaxPage then
        page = MaxPage - 1;
    elseif page <= 0 then
        page = 0;
    end
    return page;
end

function GET_CATEGORY_STRING(frame)
    if frame:GetUserIValue('isRecipeSearching') > 0 then
        return 'Recipe', 'Recipe_Detail', 'None';
    end

    local cateStr = frame:GetUserValue('SELECTED_CATEGORY');
    if cateStr == 'None' or cateStr == 'IntegrateRetreive' then
        return '';
    end
    local _cateStr = cateStr;

    local subCate = frame:GetUserValue('SELECTED_SUB_CATEGORY');
    if subCate ~= 'None' and subCate ~= 'ShowAll' then
        cateStr = cateStr .. '_' .. subCate;
    end
    return cateStr, _cateStr, subCate;
end

local function GET_SEARCH_PRICE_ORDER(frame)
    local priceOrderCheck_0 = GET_CHILD_RECURSIVELY(frame, 'priceOrderCheck_0');
    local priceOrderCheck_1 = GET_CHILD_RECURSIVELY(frame, 'priceOrderCheck_1');
    if priceOrderCheck_0 == nil or priceOrderCheck_1 == nil then
        return -1;
    end

    if priceOrderCheck_0:IsChecked() == 1 then
        return 0;
    end
    if priceOrderCheck_1:IsChecked() == 1 then
        return 1;
    end
    return 0; -- default
end

local function GET_SEARCH_TEXT(frame)
    local defaultValue = '';
    local market_search = GET_CHILD_RECURSIVELY(frame, 'itemSearchSet');
    if market_search ~= nil and market_search:IsVisible() == 1 then
        local searchEdit = GET_CHILD_RECURSIVELY(market_search, 'searchEdit');
        local findItem = searchEdit:GetText();
        searchEdit:Focus()
        local minLength = 0;
        local findItemStrLength = findItem.len(findItem);
        local maxLength = 60;
        if config.GetServiceNation() == "GLOBAL" then
            minLength = 1;
            maxLength = 20;
        elseif config.GetServiceNation() == "JPN" then
            maxLength = 60;
        elseif config.GetServiceNation() == "KOR" or config.GetServiceNation() == "GLOBAL_KOR" then
            maxLength = 60;
        end
        if findItemStrLength ~= 0 then -- 있다면 길이 조건 체크
            if findItemStrLength <= minLength then
                ui.SysMsg(ClMsg("InvalidFindItemQueryMin"));
                return defaultValue;
            elseif findItemStrLength > maxLength then
                ui.SysMsg(ClMsg("InvalidFindItemQueryMax"));
                return defaultValue;
            end
        end
        return findItem;
    end
    return defaultValue;
end

local function GET_MINMAX_QUERY_VALUE_STRING(minEdit, maxEdit)
    local queryValue = '';
    local minValue = -1000000;
    local maxValue = 1000000;
    local valid = false;
    if minEdit:GetText() ~= nil and minEdit:GetText() ~= '' then
        minValue = tonumber(minEdit:GetText());
        valid = true;
    end
    if maxEdit:GetText() ~= nil and maxEdit:GetText() ~= '' then
        maxValue = tonumber(maxEdit:GetText());
        valid = true;
    end

    if valid == false then
        return queryValue;
    end

    queryValue = minValue .. ';' .. maxValue;
    return queryValue;
end

local function GET_SEARCH_OPTION(frame)
    local optionName, optionValue = {}, {};
    local optionSet = {}; -- for checking duplicate option
    local category = frame:GetUserValue('SELECTED_CATEGORY');

    -- level range
    local levelRangeSet = GET_CHILD_RECURSIVELY(frame, 'levelRangeSet');
    if levelRangeSet ~= nil and levelRangeSet:IsVisible() == 1 then
        local minEdit = GET_CHILD_RECURSIVELY(levelRangeSet, 'minEdit');
        local maxEdit = GET_CHILD_RECURSIVELY(levelRangeSet, 'maxEdit');
        local opValue = GET_MINMAX_QUERY_VALUE_STRING(minEdit, maxEdit);
        if opValue ~= '' then
            local opName = 'CT_UseLv';
            if category == 'OPTMisc' then
                opName = 'Level';
            end
            optionName[#optionName + 1] = opName;
            optionValue[#optionValue + 1] = opValue;
            optionSet[opName] = true;
        end
    end

    -- grade
    local gradeCheckSet = GET_CHILD_RECURSIVELY(frame, 'gradeCheckSet');
    if gradeCheckSet ~= nil and gradeCheckSet:IsVisible() == 1 then
        local checkStr = '';
        local matchCnt, lastMatch = 0, nil;
        local childCnt = gradeCheckSet:GetChildCount();
        for i = 0, childCnt - 1 do
            local child = gradeCheckSet:GetChildByIndex(i);
            if string.find(child:GetName(), 'gradeCheck_') ~= nil then
                AUTO_CAST(child);
                if child:IsChecked() == 1 then
                    local grade = string.sub(child:GetName(), string.find(child:GetName(), '_') + 1);
                    checkStr = checkStr .. grade .. ';';
                    matchCnt = matchCnt + 1;
                    lastMatch = grade;
                end
            end
        end
        if checkStr ~= '' then
            if matchCnt == 1 then
                checkStr = checkStr .. lastMatch;
            end
            local opName = 'CT_ItemGrade';
            optionName[#optionName + 1] = opName;
            optionValue[#optionValue + 1] = checkStr;
            optionSet[opName] = true;
        end
    end

    -- random option flag
    local appCheckSet = GET_CHILD_RECURSIVELY(frame, 'appCheckSet');
    if appCheckSet ~= nil and appCheckSet:IsVisible() == 1 then
        local ranOpName, ranOpValue;
        local appCheck_0 = GET_CHILD(appCheckSet, 'appCheck_0');
        if appCheck_0:IsChecked() == 1 then
            ranOpName = 'Random_Item';
            ranOpValue = '2'
        end

        local appCheck_1 = GET_CHILD(appCheckSet, 'appCheck_1');
        if appCheck_1:IsChecked() == 1 then
            ranOpName = 'Random_Item';
            ranOpValue = '1'
        end

        if ranOpName ~= nil then
            optionName[#optionName + 1] = ranOpName;
            optionValue[#optionValue + 1] = ranOpValue;
            optionSet[ranOpName] = true;
        end
    end

    -- detail setting
    local detailOptionSet = GET_CHILD_RECURSIVELY(frame, 'detailOptionSet');
    if detailOptionSet ~= nil and detailOptionSet:IsVisible() == 1 then
        local curCnt = detailOptionSet:GetUserIValue('ADD_SELECT_COUNT');
        for i = 0, curCnt do
            local selectSet = GET_CHILD_RECURSIVELY(detailOptionSet, 'SELECT_' .. i);
            if selectSet ~= nil and selectSet:IsVisible() == 1 then
                local nameList = GET_CHILD(selectSet, 'groupList');
                local opName = nameList:GetSelItemKey();
                if opName ~= '' then
                    local opValue = GET_MINMAX_QUERY_VALUE_STRING(GET_CHILD_RECURSIVELY(selectSet, 'minEdit'),
                                                                  GET_CHILD_RECURSIVELY(selectSet, 'maxEdit'));
                    if opValue ~= '' and optionSet[opName] == nil then
                        optionName[#optionName + 1] = opName;
                        optionValue[#optionValue + 1] = opValue;
                        optionSet[opName] = true;
                    end
                end
            end
        end
    end

    -- option group
    local optionGroupSet = GET_CHILD_RECURSIVELY(frame, 'optionGroupSet');
    if optionGroupSet ~= nil and optionGroupSet:IsVisible() == 1 then
        local curCnt = optionGroupSet:GetUserIValue('ADD_SELECT_COUNT');
        for i = 0, curCnt do
            local selectSet = GET_CHILD_RECURSIVELY(optionGroupSet, 'SELECT_' .. i);
            if selectSet ~= nil then
                local nameList = GET_CHILD(selectSet, 'nameList');
                local opName = nameList:GetSelItemKey();
                if opName ~= '' then
                    local opValue = GET_MINMAX_QUERY_VALUE_STRING(GET_CHILD_RECURSIVELY(selectSet, 'minEdit'),
                                                                  GET_CHILD_RECURSIVELY(selectSet, 'maxEdit'));
                    if opValue ~= '' and optionSet[opName] == nil then
                        optionName[#optionName + 1] = opName;
                        optionValue[#optionValue + 1] = opValue;
                        optionSet[opName] = true;
                    end
                end
            end
        end
    end

    -- gem option
    local gemOptionSet = GET_CHILD_RECURSIVELY(frame, 'gemOptionSet');
    if gemOptionSet ~= nil and gemOptionSet:IsVisible() == 1 then
        local levelMinEdit = GET_CHILD_RECURSIVELY(gemOptionSet, 'levelMinEdit');
        local levelMaxEdit = GET_CHILD_RECURSIVELY(gemOptionSet, 'levelMaxEdit');
        local roastingMinEdit = GET_CHILD_RECURSIVELY(gemOptionSet, 'roastingMinEdit');
        local roastingMaxEdit = GET_CHILD_RECURSIVELY(gemOptionSet, 'roastingMaxEdit');
        if category == 'Gem' then
            local opValue = GET_MINMAX_QUERY_VALUE_STRING(levelMinEdit, levelMaxEdit);
            if opValue ~= '' then
                optionName[#optionName + 1] = 'GemLevel';
                optionValue[#optionValue + 1] = opValue;
                optionSet['GemLevel'] = true;
            end

            local roastOpValue = GET_MINMAX_QUERY_VALUE_STRING(roastingMinEdit, roastingMaxEdit);
            if roastOpValue ~= '' then
                optionName[#optionName + 1] = 'GemRoastingLv';
                optionValue[#optionValue + 1] = roastOpValue;
                optionSet['GemRoastingLv'] = true;
            end
        elseif category == 'Card' then
            local opValue = GET_MINMAX_QUERY_VALUE_STRING(levelMinEdit, levelMaxEdit);
            if opValue ~= '' then
                optionName[#optionName + 1] = 'CardLevel';
                optionValue[#optionValue + 1] = opValue;
                optionSet['CardLevel'] = true;
            end
        end
    end

    return optionName, optionValue;
end

function MARKET_REQ_LIST(frame)
    frame = frame:GetTopParentFrame();
    MARKET_FIND_PAGE(frame, 0);
end

function MARKET_FIND_PAGE(frame, page)
    page = CLAMP_MARKET_PAGE_NUMBER(frame, 'pagecontrol', page);
    local orderByDesc = GET_SEARCH_PRICE_ORDER(frame);
    if orderByDesc < 0 then
        return;
    end
    local searchText = GET_SEARCH_TEXT(frame);
    local category, _category, _subCategory = GET_CATEGORY_STRING(frame);
    if category == '' and searchText == '' then
        return;
    end

    if searchText ~= '' and ui.GetPaperLength(searchText) < 2 then
        ui.SysMsg(ClMsg('InvalidFindItemQueryMin'));
        return;
    end

    local optionKey, optionValue = GET_SEARCH_OPTION(frame);
    local itemCntPerPage = GET_MARKET_SEARCH_ITEM_COUNT(_category);
    MarketSearch(page + 1, orderByDesc, searchText, category, optionKey, optionValue, itemCntPerPage);
    DISABLE_BUTTON_DOUBLECLICK_WITH_CHILD(frame:GetName(), 'commitSet', 'searchBtn', 1);
    MARKET_OPTION_BOX_CLOSE_CLICK(frame);
end

function MARKET_UPDATE_PRICE_ORDER(parent, ctrl)
    local frame = parent:GetTopParentFrame();
    local curClickedOrderType = tonumber(string.sub(ctrl:GetName(), string.find(ctrl:GetName(), '_') + 1));
    local otherCheckType = 0;
    if curClickedOrderType == 0 then
        otherCheckType = 1;
    end
    if ctrl:IsChecked() == 1 then
        local otherCheck = GET_CHILD_RECURSIVELY(frame, 'priceOrderCheck_' .. otherCheckType);
        otherCheck:SetCheck(0);
    else
        ctrl:SetCheck(1);
    end
end

function MARKET_UPDATE_APPRAISAL_CHECK(parent, ctrl)
    local frame = parent:GetTopParentFrame();
    local curClickedOrderType = tonumber(string.sub(ctrl:GetName(), string.find(ctrl:GetName(), '_') + 1));
    local otherCheckType = 0;
    if curClickedOrderType == 0 then
        otherCheckType = 1;
    end
    if ctrl:IsChecked() == 1 then
        local otherCheck = GET_CHILD_RECURSIVELY(frame, 'appCheck_' .. otherCheckType);
        otherCheck:SetCheck(0);
    end
end

local function ALIGN_OPTION_GROUP_SET(optionGroupSet)
    local Y_ADD_MARGIN = 6;
    local staticText = GET_CHILD(optionGroupSet, 'staticText');
    local ypos = staticText:GetY() + staticText:GetHeight() + Y_ADD_MARGIN;
    local childCnt = optionGroupSet:GetChildCount();

    local visibleSelectChildCount = 0;
    local visibleChild = nil;
    for i = 0, childCnt - 1 do
        local child = optionGroupSet:GetChildByIndex(i);
        if string.find(child:GetName(), 'SELECT_') ~= nil then
            child:SetOffset(child:GetX(), ypos);
            visibleChild = child;
            ypos = ypos + child:GetHeight();
            visibleSelectChildCount = visibleSelectChildCount + 1;
        end
    end
    local addOptionBtn = GET_CHILD(optionGroupSet, 'addOptionBtn');
    addOptionBtn:SetOffset(0, ypos);
    ypos = ypos + addOptionBtn:GetHeight() + Y_ADD_MARGIN;
    optionGroupSet:Resize(optionGroupSet:GetWidth(), ypos);
    return visibleSelectChildCount, visibleChild;
end

local function ALIGN_ALL_CATEGORY(frame)
    local cateListBox = GET_CHILD_RECURSIVELY(frame, 'cateListBox');
    local selectedCtrlset = GET_CHILD_RECURSIVELY(frame, 'CATEGORY_' .. frame:GetUserValue('SELECTED_CATEGORY'));
    local subCateBox = GET_CHILD_RECURSIVELY(frame, 'detailBox');
    GBOX_AUTO_ALIGN(subCateBox, 0, 1, 0, true, true);
    ALIGN_CATEGORY_BOX(cateListBox, selectedCtrlset, subCateBox);
end

local function GET_DETAIL_OPTION_CTRLSET_COUNT(optionGroupSet)
    local ctrlsetCnt = 0;
    local childCnt = optionGroupSet:GetChildCount();
    for i = 0, childCnt - 1 do
        local child = optionGroupSet:GetChildByIndex(i);
        if string.find(child:GetName(), 'SELECT_') ~= nil and child:IsVisible() == 1 then
            ctrlsetCnt = ctrlsetCnt + 1;
        end
    end
    return ctrlsetCnt;
end

function MARKET_ADD_SEARCH_OPTION_GROUP(optionGroupSet, ctrl, hideDeleteCtrl)
    if GET_DETAIL_OPTION_CTRLSET_COUNT(optionGroupSet) >= 8 then
        return;
    end

    local curSelectCnt = optionGroupSet:GetUserIValue('ADD_SELECT_COUNT');
    optionGroupSet:SetUserValue('ADD_SELECT_COUNT', curSelectCnt + 1);
    local childIdx = curSelectCnt;
    local selectSet = optionGroupSet:CreateOrGetControlSet('market_option_group_select', 'SELECT_' .. childIdx, 0, 0);
    local minEdit = GET_CHILD_RECURSIVELY(selectSet, 'minEdit');
    local maxEdit = GET_CHILD_RECURSIVELY(selectSet, 'maxEdit');
    minEdit:SetText('');
    maxEdit:SetText('');

    if hideDeleteCtrl == true then
        local deleteText = GET_CHILD(selectSet, 'deleteText');
        deleteText:ShowWindow(0);
        optionGroupSet:SetUserValue('HIDE_CHILD_INDEX', childIdx);
    else
        local hideChildIdx = optionGroupSet:GetUserValue('HIDE_CHILD_INDEX');
        local hideChild = GET_CHILD(optionGroupSet, 'SELECT_' .. hideChildIdx);
        if hideChild ~= nil then
            local hideDelText = GET_CHILD(hideChild, 'deleteText');
            hideDelText:ShowWindow(1);
            optionGroupSet:SetUserValue('HIDE_CHILD_INDEX', 'None');
        end
    end
    local groupList = GET_CHILD(selectSet, 'groupList');
    MARKET_INIT_OPTION_GROUP_DROPLIST(groupList);
    ALIGN_OPTION_GROUP_SET(optionGroupSet);
    ALIGN_ALL_CATEGORY(optionGroupSet:GetTopParentFrame());

    return selectSet;
end

function MARKET_DELETE_OPTION_GROUP_SELECT(selectCtrlset, ctrl)
    local optionGroupSet = selectCtrlset:GetParent();
    optionGroupSet:RemoveChild(selectCtrlset:GetName());
    local visibleChildCnt, visibleChild = ALIGN_OPTION_GROUP_SET(optionGroupSet);
    if visibleChildCnt == 1 and visibleChild ~= nil then
        local deleteText = GET_CHILD(visibleChild, 'deleteText');
        deleteText:ShowWindow(0);
        local visibleChildName = visibleChild:GetName();
        optionGroupSet:SetUserValue('HIDE_CHILD_INDEX',
                                    string.sub(visibleChildName, string.find(visibleChildName, '_') + 1));
    end
    ALIGN_ALL_CATEGORY(selectCtrlset:GetTopParentFrame());
end

function MARKET_ADD_SEARCH_DETAIL_SETTING(detailOptionSet, ctrl, hideDeleteCtrl)
    if GET_DETAIL_OPTION_CTRLSET_COUNT(detailOptionSet) >= 3 then
        return;
    end

    local frame = detailOptionSet:GetTopParentFrame();
    local curSelectCnt = detailOptionSet:GetUserIValue('ADD_SELECT_COUNT');
    detailOptionSet:SetUserValue('ADD_SELECT_COUNT', curSelectCnt + 1);

    local childIdx = curSelectCnt;
    local selectSet = detailOptionSet:CreateOrGetControlSet('market_detail_option_select', 'SELECT_' .. childIdx, 0, 0);
    local minEdit = GET_CHILD_RECURSIVELY(selectSet, 'minEdit');
    local maxEdit = GET_CHILD_RECURSIVELY(selectSet, 'maxEdit');
    minEdit:SetText('');
    maxEdit:SetText('');

    if hideDeleteCtrl == true then
        local deleteText = GET_CHILD(selectSet, 'deleteText');
        deleteText:ShowWindow(0);
        detailOptionSet:SetUserValue('HIDE_CHILD_INDEX', childIdx);
    else
        local hideChildIdx = detailOptionSet:GetUserValue('HIDE_CHILD_INDEX');
        local hideChild = GET_CHILD(detailOptionSet, 'SELECT_' .. hideChildIdx);
        if hideChild ~= nil then
            local hideDelText = GET_CHILD(hideChild, 'deleteText');
            hideDelText:ShowWindow(1);
            detailOptionSet:SetUserValue('HIDE_CHILD_INDEX', 'None');
        end
    end

    MARKET_INIT_DETAIL_SETTING_DROPLIST(GET_CHILD(selectSet, 'groupList'));
    ALIGN_OPTION_GROUP_SET(detailOptionSet);
    ALIGN_ALL_CATEGORY(detailOptionSet:GetTopParentFrame());
    return selectSet;
end

function MARKET_REFRESH_SEARCH_OPTION(parent, ctrl)
    local frame = parent:GetTopParentFrame();

    -- price order
    local priceOrderCheck = GET_CHILD_RECURSIVELY(frame, 'priceOrderCheck_0');
    priceOrderCheck:SetCheck(1);
    MARKET_UPDATE_PRICE_ORDER(priceOrderCheck:GetParent(), priceOrderCheck);

    -- level range
    local levelRangeSet = GET_CHILD_RECURSIVELY(frame, 'levelRangeSet');
    if levelRangeSet ~= nil and levelRangeSet:IsVisible() == 1 then
        local minEdit = GET_CHILD_RECURSIVELY(levelRangeSet, 'minEdit');
        local maxEdit = GET_CHILD_RECURSIVELY(levelRangeSet, 'maxEdit');
        minEdit:SetText('');
        maxEdit:SetText('');
    end

    -- item grade
    local gradeCheckSet = GET_CHILD_RECURSIVELY(frame, 'gradeCheckSet');
    if gradeCheckSet ~= nil and gradeCheckSet:IsVisible() == 1 then
        for i = 1, 5 do
            local check = GET_CHILD_RECURSIVELY(gradeCheckSet, 'gradeCheck_' .. i);
            check:SetCheck(1);
        end
    end

    -- search
    local itemSearchSet = GET_CHILD_RECURSIVELY(frame, 'itemSearchSet');
    if itemSearchSet ~= nil and itemSearchSet:IsVisible() == 1 then
        local searchEdit = GET_CHILD_RECURSIVELY(itemSearchSet, 'searchEdit');
        searchEdit:SetText('');
        searchEdit:Focus()
    end

    -- appraisal
    local appCheckSet = GET_CHILD_RECURSIVELY(frame, 'appCheckSet');
    if appCheckSet ~= nil and appCheckSet:IsVisible() == 1 then
        for i = 0, 1 do
            local appCheck = GET_CHILD(appCheckSet, 'appCheck_' .. i);
            appCheck:SetCheck(0);
        end
    end

    local detailBox = GET_CHILD_RECURSIVELY(frame, 'detailBox');
    -- detail setting	
    local detailOptionSet = GET_CHILD_RECURSIVELY(frame, 'detailOptionSet');
    if detailOptionSet ~= nil and detailOptionSet:IsVisible() == 1 then
        DESTROY_CHILD_BYNAME(detailOptionSet, 'SELECT_');
        detailOptionSet:SetUserValue('ADD_SELECT_COUNT', 0);

        local market_detail_setting = detailBox:CreateOrGetControlSet('market_detail_setting', 'detailOptionSet', 0, 0);
        MARKET_ADD_SEARCH_DETAIL_SETTING(market_detail_setting, nil, true);

        ALIGN_OPTION_GROUP_SET(detailOptionSet);
    end

    -- option group
    local optionGroupSet = GET_CHILD_RECURSIVELY(frame, 'optionGroupSet');
    if optionGroupSet ~= nil and optionGroupSet:IsVisible() == 1 then
        DESTROY_CHILD_BYNAME(optionGroupSet, 'SELECT_');
        optionGroupSet:SetUserValue('ADD_SELECT_COUNT', 0);

        local market_option_group = detailBox:CreateOrGetControlSet('market_option_group', 'optionGroupSet', 0, 0);
        MARKET_ADD_SEARCH_OPTION_GROUP(market_option_group, nil, true);

        ALIGN_OPTION_GROUP_SET(optionGroupSet);
    end

    -- gem
    local gemOptionSet = GET_CHILD_RECURSIVELY(frame, 'gemOptionSet');
    if gemOptionSet ~= nil and gemOptionSet:IsVisible() == 1 then
        local levelMinEdit = GET_CHILD_RECURSIVELY(gemOptionSet, 'levelMinEdit');
        local levelMaxEdit = GET_CHILD_RECURSIVELY(gemOptionSet, 'levelMaxEdit');
        local roastingMinEdit = GET_CHILD_RECURSIVELY(gemOptionSet, 'roastingMinEdit');
        local roastingMaxEdit = GET_CHILD_RECURSIVELY(gemOptionSet, 'roastingMaxEdit');
        levelMinEdit:SetText('');
        levelMaxEdit:SetText('');
        roastingMinEdit:SetText('');
        roastingMaxEdit:SetText('');
    end

    ALIGN_ALL_CATEGORY(frame);
end

function MARKET_SAVE_CATEGORY_OPTION(parent, ctrl)
    local configKeyList = GetMarketCategoryConfigKeyList();
    if #configKeyList > 19 then
        ui.SysMsg(ClMsg('TooManyMarketSaveOption'))
        return;
    end

    local frame = parent:GetTopParentFrame();
    local orderByDesc = GET_SEARCH_PRICE_ORDER(frame);
    local searchText = GET_SEARCH_TEXT(frame);
    local category = GET_CATEGORY_STRING(frame);
    local optionKey, optionValue = GET_SEARCH_OPTION(frame);

    local saveConfigNameEdit = GET_CHILD(parent, 'saveConfigNameEdit');
    local configKey = saveConfigNameEdit:GetText();
    if configKey == nil or configKey == '' then
        ui.SysMsg(ClMsg('InputTitlePlease'));
        return;
    end

    local length = ui.GetCharNameLength(configKey);
    if length > 50 then
        ui.SysMsg(ClMsg('OverLength'));
        return;
    end

    local configText = session.market.GetCategoryConfig(configKey);
    if configText ~= nil and configText ~= '' then
        ui.SysMsg(ClMsg('Auto_iMi_JonJaeHaNeun_iLeumipNiDa'));
        return;
    end

    local badword = IsBadString(configKey);
    if badword ~= nil then
        ui.SysMsg(ScpArgMsg('{Word}_FobiddenWord', 'Word', badword));
        return;
    end

    _MARKET_SAVE_CATEGORY_OPTION(frame, configKey, orderByDesc, searchText, category, optionKey, optionValue);
end

function _MARKET_SAVE_CATEGORY_OPTION(frame, configKey, orderByDesc, searchText, category, optionKey, optionValue)
    local serialize = string.format('order:%d@searchText:%s@category:%s', orderByDesc, searchText, category);
    for i = 1, #optionKey do
        serialize = serialize .. '@' .. optionKey[i] .. ':' .. optionValue[i];
    end

    session.market.SaveCategoryConfig(configKey, serialize);

    local optionBox = GET_CHILD_RECURSIVELY(frame, 'optionBox');
    optionBox:ShowWindow(0);
end

local function GET_MINMAX_VALUE_BY_QUERY_STRING(queryString)
    local semiColonIdx = string.find(queryString, ';');
    local minValue = tonumber(string.sub(queryString, 0, semiColonIdx - 1));
    local maxValue = tonumber(string.sub(queryString, semiColonIdx + 1));
    minValue = math.max(minValue, 0);
    maxValue = math.max(maxValue, 0);
    return minValue, maxValue;
end

function MARKET_LOAD_CATEGORY_OPTION(parent, ctrl, argStr)
    local frame = parent:GetTopParentFrame();
    local optionBox = GET_CHILD_RECURSIVELY(frame, 'optionBox');
    optionBox:ShowWindow(0);

    function _MARKET_LOAD_CATEGORY_OPTION(frame, configKey)
        frame = frame:GetTopParentFrame();
        local configText = session.market.GetCategoryConfig(configKey);
        if configText == nil or configText == '' then
            return false;
        end

        -- parse
        local configList = StringSplit(configText, '@');
        local configTable = {};
        for i = 1, #configList do
            local config = configList[i];
            local idx = string.find(config, ':');
            if idx == nil then
                return false;
            end
            local propName = string.sub(config, 0, idx - 1);
            local propValue = string.sub(config, idx + 1);
            configTable[propName] = propValue;
        end

        -- set category
        local categoryStr = configTable['category'];
        local underBarIdx = string.find(categoryStr, '_');
        local category = categoryStr;
        local subCategory = '';
        if underBarIdx ~= nil then
            category = string.sub(categoryStr, 0, underBarIdx - 1);
            subCategory = string.sub(categoryStr, underBarIdx + 1);
        end
        if category == '' then
            category = 'IntegrateRetreive';
        end

        local categoryCtrlset = GET_CHILD_RECURSIVELY(frame, 'CATEGORY_' .. category);
        MARKET_CATEGORY_CLICK(categoryCtrlset, categoryCtrlset:GetChild('bgBox'), false, true);

        if subCategory ~= '' then
            local subCategoryCtrlset = GET_CHILD_RECURSIVELY(frame, 'SUB_CATE_' .. subCategory);
            if subCategoryCtrlset ~= nil then
                MARKET_SUB_CATEOGRY_CLICK(subCategoryCtrlset:GetParent(), subCategoryCtrlset, false);
            end
        end

        -- set price order
        local checkIdx = configTable['order'];
        local priceOrderCheck = GET_CHILD_RECURSIVELY(frame, 'priceOrderCheck_' .. checkIdx);
        priceOrderCheck:SetCheck(1);
        MARKET_UPDATE_PRICE_ORDER(frame, priceOrderCheck);

        -- set level range
        if configTable['CT_UseLv'] ~= nil or configTable['Level'] ~= nil then
            local levelRangeSet = GET_CHILD_RECURSIVELY(frame, 'levelRangeSet');
            if levelRangeSet ~= nil and levelRangeSet:IsVisible() == 1 then
                local rangeValue = configTable['CT_UseLv'];
                if configTable['Level'] ~= nil then
                    rangeValue = configTable['Level'];
                end
                local minValue, maxValue = GET_MINMAX_VALUE_BY_QUERY_STRING(rangeValue);
                local minEdit = GET_CHILD_RECURSIVELY(levelRangeSet, 'minEdit');
                local maxEdit = GET_CHILD_RECURSIVELY(levelRangeSet, 'maxEdit');
                minEdit:SetText(minValue);
                maxEdit:SetText(maxValue);
            end
        end

        -- set item grade	
        local gradeCheckSet = GET_CHILD_RECURSIVELY(frame, 'gradeCheckSet');
        if gradeCheckSet ~= nil then
            local gradeChildCnt = gradeCheckSet:GetChildCount(); -- init
            for i = 0, gradeChildCnt - 1 do
                local child = gradeCheckSet:GetChildByIndex(i);
                if string.find(child:GetName(), 'gradeCheck_') ~= nil then
                    AUTO_CAST(child);
                    child:SetCheck(0);
                end
            end
            if configTable['CT_ItemGrade'] ~= nil then
                if gradeCheckSet ~= nil and gradeCheckSet:IsVisible() == 1 then
                    local checkValue = configTable['CT_ItemGrade'];
                    local checkValueList = StringSplit(checkValue, ';');

                    -- set check
                    for i = 1, #checkValueList do
                        local gradeCheck = GET_CHILD(gradeCheckSet, 'gradeCheck_' .. checkValueList[i]);
                        gradeCheck:SetCheck(1);
                    end
                end
            end
        end

        -- set search text
        local itemSearchSet = GET_CHILD_RECURSIVELY(frame, 'itemSearchSet');
        local searchEdit = GET_CHILD_RECURSIVELY(itemSearchSet, 'searchEdit');
        searchEdit:SetText(configTable['searchText']);

        -- set appraisal check
        if configTable['Random_Item'] ~= nil then
            local appCheckSet = GET_CHILD_RECURSIVELY(frame, 'appCheckSet');
            if appCheckSet ~= nil and appCheckSet:IsVisible() == 1 then
                local configValue = tonumber(configTable['Random_Item']);
                local checkCtrl = nil;
                if configValue == 1 then
                    checkCtrl = GET_CHILD(appCheckSet, 'appCheck_1');
                elseif configValue == 2 then
                    checkCtrl = GET_CHILD(appCheckSet, 'appCheck_0');
                end
                if checkCtrl ~= nil then
                    checkCtrl:SetCheck(1);
                    MARKET_UPDATE_APPRAISAL_CHECK(checkCtrl:GetParent(), checkCtrl);
                end
            end
        end

        -- detail setting
        local detailOptionSet = GET_CHILD_RECURSIVELY(frame, 'detailOptionSet');
        if detailOptionSet ~= nil and detailOptionSet:IsVisible() == 1 then
            local added = false;
            for configName, configValue in pairs(configTable) do
                if IS_MARKET_DETAIL_SETTING_OPTION(configName) == true then
                    local selectSet = MARKET_ADD_SEARCH_DETAIL_SETTING(detailOptionSet);
                    local groupList = GET_CHILD(selectSet, 'groupList');
                    groupList:SelectItemByKey(configName);

                    local minValue, maxValue = GET_MINMAX_VALUE_BY_QUERY_STRING(configValue);
                    local minEdit, maxEdit = GET_CHILD_RECURSIVELY(selectSet, 'minEdit'),
                                             GET_CHILD_RECURSIVELY(selectSet, 'maxEdit');
                    minEdit:SetText(minValue);
                    maxEdit:SetText(maxValue);

                    added = true;
                end
            end
            if added == false then
                ALIGN_OPTION_GROUP_SET(detailOptionSet);
            end
        end

        -- option group
        local optionGroupSet = GET_CHILD_RECURSIVELY(frame, 'optionGroupSet');
        if optionGroupSet ~= nil and optionGroupSet:IsVisible() == 1 then
            local added = false;
            for configName, configValue in pairs(configTable) do
                local isOptionGroup, group = IS_MARKET_SEARCH_OPTION_GROUP(configName);
                if isOptionGroup == true then
                    local selectSet = MARKET_ADD_SEARCH_OPTION_GROUP(optionGroupSet);
                    local groupList = GET_CHILD(selectSet, 'groupList');
                    groupList:SelectItemByKey(group);
                    MARKET_INIT_OPTION_GROUP_VALUE_DROPLIST(groupList:GetParent(), groupList);

                    local nameList = GET_CHILD(selectSet, 'nameList');
                    nameList:SelectItemByKey(configName);

                    local minValue, maxValue = GET_MINMAX_VALUE_BY_QUERY_STRING(configValue);
                    local minEdit, maxEdit = GET_CHILD_RECURSIVELY(selectSet, 'minEdit'),
                                             GET_CHILD_RECURSIVELY(selectSet, 'maxEdit');
                    minEdit:SetText(minValue);
                    maxEdit:SetText(maxValue);

                    added = true;
                end
            end
            if added == false then
                ALIGN_OPTION_GROUP_SET(optionGroupSet);
            end
        end

        -- gem
        local gemOptionSet = GET_CHILD_RECURSIVELY(frame, 'gemOptionSet');
        if gemOptionSet ~= nil then
            if configTable['GemLevel'] ~= nil then
                local minValue, maxValue = GET_MINMAX_VALUE_BY_QUERY_STRING(configTable['GemLevel']);
                local minEdit, maxEdit = GET_CHILD_RECURSIVELY(selectSet, 'levelMinEdit'),
                                         GET_CHILD_RECURSIVELY(selectSet, 'levelMaxEdit');
                minEdit:SetText(minValue);
                maxEdit:SetText(maxValue);
            end
            if configTable['CardLevel'] ~= nil then
                local minValue, maxValue = GET_MINMAX_VALUE_BY_QUERY_STRING(configTable['CardLevel']);
                local minEdit, maxEdit = GET_CHILD_RECURSIVELY(selectSet, 'levelMinEdit'),
                                         GET_CHILD_RECURSIVELY(selectSet, 'levelMaxEdit');
                minEdit:SetText(minValue);
                maxEdit:SetText(maxValue);
            end
            if configTable['GemRoastingLv'] ~= nil then
                local minValue, maxValue = GET_MINMAX_VALUE_BY_QUERY_STRING(configTable['CardLevel']);
                local minEdit, maxEdit = GET_CHILD_RECURSIVELY(selectSet, 'levelMinEdit'),
                                         GET_CHILD_RECURSIVELY(selectSet, 'levelMaxEdit');
                minEdit:SetText(minValue);
                maxEdit:SetText(maxValue);
            end
        end

        -- saveBtn
        local saveCheck = GET_CHILD_RECURSIVELY(frame, 'saveCheck');
        if saveCheck ~= nil then
            saveCheck:SetCheck(1);
        end

        ALIGN_ALL_CATEGORY(frame);
        MARKET_REQ_LIST(frame);
        return true;
    end
    _MARKET_LOAD_CATEGORY_OPTION(frame, argStr);
end

function MARKET_TRY_SAVE_CATEGORY_OPTION(parent, ctrl)
    local frame = parent:GetTopParentFrame();
    local optionBox = GET_CHILD_RECURSIVELY(frame, 'optionBox');
    optionBox:ShowWindow(1);

    local optionSaveBox = GET_CHILD(optionBox, 'optionSaveBox');
    local saveConfigNameEdit = GET_CHILD(optionSaveBox, 'saveConfigNameEdit');
    saveConfigNameEdit:SetText('');
    optionSaveBox:ShowWindow(1);

    local optionLoadBox = GET_CHILD(optionBox, 'optionLoadBox');
    optionLoadBox:ShowWindow(0);
end

function MARKET_TRY_LOAD_CATEGORY_OPTION(parent, ctrl)
    local frame = parent:GetTopParentFrame();
    local optionBox = GET_CHILD_RECURSIVELY(frame, 'optionBox');
    optionBox:ShowWindow(1);

    local optionSaveBox = GET_CHILD(optionBox, 'optionSaveBox');
    local optionLoadBox = GET_CHILD(optionBox, 'optionLoadBox');
    optionSaveBox:ShowWindow(0);
    optionLoadBox:ShowWindow(1);

    local optionListBox = GET_CHILD(optionLoadBox, 'optionListBox');
    optionListBox:RemoveAllChild();

    local ypos = 0;
    local CATEGORY_SAVE_OPTION_SKIN = frame:GetUserConfig('CATEGORY_SAVE_OPTION_SKIN');
    local configKeyList = GetMarketCategoryConfigKeyList();
    local showCnt = 0;
    for i = 1, #configKeyList do
        if configKeyList[i] ~= '' then
            local keyText = optionListBox:CreateOrGetControlSet('market_save_option', 'CONFIG_' .. i, 0, ypos);
            local nameText = GET_CHILD(keyText, 'nameText');
            nameText:SetText(configKeyList[i]);
            nameText:SetTextTooltip(configKeyList[i]);
            nameText:SetEventScript(ui.LBUTTONUP, 'MARKET_LOAD_CATEGORY_OPTION');
            nameText:SetEventScriptArgString(ui.LBUTTONUP, configKeyList[i]);

            if showCnt % 2 == 1 then
                local skinBox = GET_CHILD(keyText, 'skinBox');
                skinBox:SetSkinName(CATEGORY_SAVE_OPTION_SKIN);
            end
            showCnt = showCnt + 1;

            ypos = ypos + keyText:GetHeight();
        end
    end
end

function MARKET_REQ_RECIPE_LIST(frame, page, recipeCls)
    page = CLAMP_MARKET_PAGE_NUMBER(frame, 'pagecontrol_material', page);

    local materialList = '';
    for i = 1, MAX_RECIPE_MATERIAL_COUNT do
        local materialItem = recipeCls["Item_" .. i .. "_1"];
        if materialItem ~= nil and materialItem ~= "None" then
            local itemCls = GetClass("Item", materialItem)
            materialList = materialList .. itemCls.ClassID .. ";";
        end
    end

    local itemCntPerPage = GET_MARKET_SEARCH_ITEM_COUNT('RecipeMaterial');
    MarketRecipeSearch(page + 1, materialList, itemCntPerPage);
    MARKET_OPTION_BOX_CLOSE_CLICK(frame);
end

function ON_MARKET_ESCAPE_PRESSED(frame)
    local optionBox = GET_CHILD_RECURSIVELY(frame, 'optionBox');
    if optionBox:IsVisible() == 1 then
        optionBox:ShowWindow(0);
        return 0;
    end
    frame:ShowWindow(0);
    return 1;
end

function MARKET_OPTION_BOX_CLOSE_CLICK(parent, closeBtn)
    local frame = parent:GetTopParentFrame();
    local optionBox = GET_CHILD_RECURSIVELY(frame, 'optionBox');
    optionBox:ShowWindow(0);
end

function MARKET_SEARCH_RECIPE_IN_DETAIL_MODE(frame, pageControl, ctrlset)
    local clickedCtrlSetName = ctrlset:GetName();
    local splited = StringSplit(clickedCtrlSetName, '_');
    local curItemIdx = tonumber(splited[3]) + GET_MARKET_SEARCH_ITEM_COUNT('Recipe') * pageControl:GetCurPage();
    local pageInRecipeDetailMode = math.floor(curItemIdx / GET_MARKET_SEARCH_ITEM_COUNT('Recipe_Detail'));
    MARKET_FIND_PAGE(frame, pageInRecipeDetailMode);
end

function MARKET_DELETE_SAVED_OPTION(parent, ctrl)
    local nameText = GET_CHILD(parent, 'nameText');
    session.market.DeleteCategoryConfig(nameText:GetText());
    MARKET_TRY_LOAD_CATEGORY_OPTION(parent);
end

function MARKET_CATEGORY_CHECK_DUPLICATE_OPTION(parent, ctrl)
    local selectedKey = ctrl:GetSelItemKey();
    if selectedKey == '' then
        return;
    end

    local groupSet = parent:GetParent();
    local childCnt = groupSet:GetChildCount();
    local optionSet = {};
    for i = 0, childCnt - 1 do
        local child = groupSet:GetChildByIndex(i);
        if string.find(child:GetName(), 'SELECT_') ~= nil then
            local droplist = GET_CHILD_RECURSIVELY(child, ctrl:GetName());
            local selectedValue = droplist:GetSelItemKey();
            if selectedValue ~= '' then
                if optionSet[selectedValue] ~= nil then
                    ui.SysMsg(ClMsg('DuplicateMarketSearchOption'));
                    ctrl:SelectItemByKey('');
                    return;
                end
                optionSet[selectedValue] = true;
            end
        end
    end
end
local MARKET_OPTION_GROUP_PROP_LIST = {
    STAT = {"STR", "DEX", "INT", "CON", "MNA"},
    UTIL = {"BLK", "BLK_BREAK", "ADD_HR", "ADD_DR", "CRTHR", "CRTDR", "MHP", "MSP", "MSTA", "RHP", "RSP",
            "LootingChance"},
    MARKET_DEF = {"ADD_DEF", "ADD_MDEF", "AriesDEF", "SlashDEF", "StrikeDEF", "RES_FIRE", "RES_ICE", "RES_POISON",
                  "RES_LIGHTNING", "RES_EARTH", "RES_SOUL", "RES_HOLY", "RES_DARK", "CRTDR", "Cloth_Def", "Leather_Def",
                  "Iron_Def", "MiddleSize_Def", "ResAdd_Damage", "stun_res", "high_fire_res", "high_freezing_res",
                  "high_lighting_res", "high_poison_res", "high_laceration_res", "portion_expansion"},
    MARKET_ATK = {"PATK", "ADD_MATK", "CRTATK", "CRTMATK", "ADD_CLOTH", "ADD_LEATHER", "ADD_IRON", "ADD_SMALLSIZE",
                  "ADD_MIDDLESIZE", "ADD_LARGESIZE", "ADD_GHOST", "ADD_FORESTER", "ADD_WIDLING", "ADD_VELIAS",
                  "ADD_PARAMUNE", "ADD_KLAIDA", "ADD_FIRE", "ADD_ICE", "ADD_POISON", "ADD_LIGHTNING", "ADD_EARTH",
                  "ADD_SOUL", "ADD_HOLY", "ADD_DARK", "Add_Damage_Atk", "ADD_BOSS_ATK", "AllMaterialType_Atk",
                  "AllRace_Atk", "perfection", "revenge"},
    ETC = {"SR", "MSPD", "SDR"},
    MARKET_ENCHANT = {"RareOption_SR", "RareOption_MSPD", "RareOption_BlockRate", "RareOption_BlockBreakRate",
                      "RareOption_DodgeRate", "RareOption_HitRate", "RareOption_CriticalDodgeRate",
                      "RareOption_CriticalHitRate", "RareOption_PVPReducedRate", "RareOption_MeleeReducedRate",
                      "RareOption_MagicReducedRate", "RareOption_CriticalDamage_Rate", "RareOption_PVPDamageRate",
                      "RareOption_BossDamageRate", "RareOption_MainWeaponDamageRate"},
    MARKET_SPECIAL = {"normalatk_enhance", "heal_dark_sphere", "chain_lightning", "meteor", "dark_lash", "whirlwind",
                      "poison_arrow", "energy_bullet", "ice_orb", "gravitation_spear", "carnage_scythe", "ice_arrow",
                      "walking_recover_sta", "reduce_rsp_time", "secret_medicine_time", "ignore_deadremove"}
};

local MARKET_DETAIL_SETTING_LIST = {"Transcend", "Reinforce_2", "PR", "Grade"};

local MARKET_ITEM_COUNT_PER_PAGE = {
    Weapon = 7,
    Armor = 7,
    Accessory = 7,
    HairAcc = 7,
    RecipeMaterial = 7,
    Recipe_Detail = 3,
    OPTMisc = 7,
    Gem = 7,
    Default = 11
};

function IS_MARKET_DETAIL_SETTING_OPTION(optionName)
    for i = 1, #MARKET_DETAIL_SETTING_LIST do
        if MARKET_DETAIL_SETTING_LIST[i] == optionName then
            return true;
        end
    end
    return false;
end

function IS_MARKET_SEARCH_OPTION_GROUP(optionName)
    for group, list in pairs(MARKET_OPTION_GROUP_PROP_LIST) do
        for i = 1, #list do
            if optionName == list[i] then
                return true, group;
            end
        end
    end
    return false;
end

function MARKET_INIT_OPTION_GROUP_DROPLIST(dropList)
    dropList:ClearItems();
    dropList:AddItem('', '');
    for group, list in pairs(MARKET_OPTION_GROUP_PROP_LIST) do
        dropList:AddItem(group, ClMsg(group));
    end
    MARKET_INIT_OPTION_GROUP_VALUE_DROPLIST(dropList:GetParent(), dropList);
end

function MARKET_INIT_OPTION_GROUP_VALUE_DROPLIST(optionGroupSet, groupList)
    local selectedGroup = groupList:GetSelItemKey();
    local nameList = GET_CHILD(optionGroupSet, 'nameList');
    local nameValueList = MARKET_OPTION_GROUP_PROP_LIST[selectedGroup];
    nameList:ClearItems();
    nameList:AddItem('', '');
    if nameValueList ~= nil then
        for i = 1, #nameValueList do
            nameList:AddItem(nameValueList[i], ClMsg(nameValueList[i]));
        end
    end
end

function MARKET_INIT_DETAIL_SETTING_DROPLIST(groupList)
    groupList:ClearItems();
    groupList:AddItem('', '');
    for i = 1, #MARKET_DETAIL_SETTING_LIST do
        local group = MARKET_DETAIL_SETTING_LIST[i];
        groupList:AddItem(group, ClMsg(group));
    end
end

function GET_MARKET_SEARCH_ITEM_COUNT(category)
    if MARKET_ITEM_COUNT_PER_PAGE[category] == nil then
        return MARKET_ITEM_COUNT_PER_PAGE['Default'];
    end
    return MARKET_ITEM_COUNT_PER_PAGE[category];
end
