function SCR_USE_ITEM_CUPON_GIFTBOX(pc)
    local tx = TxBegin(pc) 
    TxGiveItem(tx, "Hat_629003", 1, "CUPON_GIFTBOX")
    local ret = TxCommit(tx)
end