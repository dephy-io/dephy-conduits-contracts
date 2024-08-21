package logic

import (
	"dephy-conduits/dao"
	"math/big"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/jinzhu/gorm"
)

func ParseTransfer(chainId uint64, vLog types.Log) (err error) {
	to := common.BytesToAddress(vLog.Topics[2].Bytes()).Hex()
	autherizationId := new(big.Int).SetBytes(vLog.Topics[3].Bytes())

	rentalInfo, err := dao.GetCurrentRentalInfoByAutherizationId(chainId, autherizationId.String())
	if err != nil {
		if gorm.IsRecordNotFoundError(err) {
			// AutherizationId not mint by marketplace
			return nil
		}
		return
	}

	if rentalInfo.Tenant != to {
		rentalInfo.Tenant = to
	}

	err = dao.UpdateRentalInfo(rentalInfo)
	if err != nil {
		return
	}

	return
}
