package dao

import (
	"database/sql"
	"dephy-conduits/model"
)

func InsertBookmark(chainId uint64, contract string, blockNumber uint64) (err error) {
	if err = db.Create(&model.Bookmark{
		ChainId:     chainId,
		Contract:    contract,
		BlockNumber: blockNumber,
	}).Error; err != nil {
		return
	}

	return nil
}

func UpdateBookmark(chainId uint64, contract string, blockNumber uint64) (err error) {
	if err = db.Model(&model.Bookmark{}).Where(&model.Bookmark{
		ChainId:  chainId,
		Contract: contract,
	}).Update("block_number", blockNumber).Error; err != nil {
		return
	}
	return nil
}

func GetBookmark(chainId uint64, contract string) (_ uint64, err error) {
	var bookmark *model.Bookmark
	query := db.Where(&model.Bookmark{ChainId: chainId, Contract: contract}).Find(&bookmark)
	if err = query.Error; err != nil {
		return
	}

	if query.RowsAffected == 0 {
		return 0, sql.ErrNoRows
	}

	return bookmark.BlockNumber, nil
}
