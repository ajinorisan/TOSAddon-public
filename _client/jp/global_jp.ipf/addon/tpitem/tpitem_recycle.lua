-- 리사이클 샵 카테고리 없앰
function RECYCLE_MAKE_TREE(frame)
	local recycleCateTree = GET_CHILD_RECURSIVELY(frame, 'recycleCateTree');
	recycleCateTree:Clear();
	recycleCateTree:SetFitToChild(true,10);
	DESTROY_CHILD_BYNAME(recycleCateTree, 'CATEGORY_');
	recycleCateTree:CloseNodeAll();

	-- TODO: 추후 카테고리를 늘릴 때에는 여기 아래를 수정하면 됨. 지금은 고정된 것들만 하기로 하였음
	local firstItem = RECYCLE_CREATE_CATEGORY_ITEM(recycleCateTree, 'TotalTabName');
--	RECYCLE_CREATE_CATEGORY_ITEM(recycleCateTree, 'Wiki_Accessory');
--	RECYCLE_CREATE_CATEGORY_ITEM(recycleCateTree, 'Artefact');
--	RECYCLE_CREATE_CATEGORY_ITEM(recycleCateTree, 'Com_costume_M');
--	RECYCLE_CREATE_CATEGORY_ITEM(recycleCateTree, 'War_costume_F');
--	RECYCLE_CREATE_CATEGORY_ITEM(recycleCateTree, 'Wiz_costume_F');
--	RECYCLE_CREATE_CATEGORY_ITEM(recycleCateTree, 'Arc_costume_F');
--	RECYCLE_CREATE_CATEGORY_ITEM(recycleCateTree, 'Cle_costume_F');
	--RECYCLE_CREATE_CATEGORY_ITEM(recycleCateTree, 'Drug');
	recycleCateTree:OpenNodeAll();
end
