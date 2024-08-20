package logic

import (
	"dephy-conduits/dao"
	"math/big"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
)

func ParseTransfer(chainId uint64, vLog types.Log) (err error) {
	to := common.BytesToAddress(vLog.Topics[2].Bytes()).Hex()
	instanceId := new(big.Int).SetBytes(vLog.Topics[3].Bytes())

	rentalInfo, err := dao.GetCurrentRentalInfoByInstanceId(chainId, instanceId.String())
	if err != nil {
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
