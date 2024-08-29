package logic

import (
	"context"
	"dephy-conduits/config"
	"dephy-conduits/constants"
	"dephy-conduits/contracts"
	"dephy-conduits/dao"
	"dephy-conduits/model"
	"dephy-conduits/utils"
	"errors"
	"log"
	"math/big"
	"time"

	"github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
)

func ParseRent(chainId uint64, vLog types.Log) (err error) {
	eventData := struct {
		StartTime   *big.Int
		EndTime     *big.Int
		RentalDays  *big.Int
		PrepaidRent *big.Int
	}{}
	err = contracts.AbiMarketplace.UnpackIntoInterface(&eventData, "Rent", vLog.Data)
	if err != nil {
		return
	}

	device := common.BytesToAddress(vLog.Topics[1].Bytes()).Hex()
	accessId := new(big.Int).SetBytes(vLog.Topics[2].Bytes())
	tenant := common.BytesToAddress(vLog.Topics[3].Bytes()).Hex()
	accessURI, err := getTokenURI(chainId, accessId)
	if err != nil {
		return
	}

	rentalInfo := &model.RentalInfo{
		ChainId:       chainId,
		TxHash:        vLog.TxHash.Hex(),
		BlockNumber:   vLog.BlockNumber,
		Device:        device,
		AccessId:      accessId.String(),
		AccessURI:     accessURI,
		Tenant:        tenant,
		StartTime:     eventData.StartTime.String(),
		EndTime:       eventData.EndTime.String(),
		RentalDays:    eventData.RentalDays.String(),
		TotalPaidRent: eventData.PrepaidRent.String(),
		RentalStatus:  model.RSRenting,
		CreateAt:      time.Now(),
	}

	err = dao.CreateRentalInfo(rentalInfo)
	if err != nil {
		return
	}

	return
}

func getTokenURI(chainId uint64, accessId *big.Int) (string, error) {
	var contract common.Address
	if chainId == constants.BASE_SEPOLIA {
		contract = common.HexToAddress(config.Config.Contracts.BASE_SEPOLIA.Marketplace.Address)
	} else {
		return "", errors.New("unsupported chain id")
	}

	ethClient, err := utils.GetEthClient(chainId)
	if err != nil {
		log.Fatalf("[%d]: GetEthClient failed, %v", chainId, err)
		return "", err
	}

	callData, err := contracts.AbiMarketplace.Pack("tokenURI", accessId)
	if err != nil {
		return "", err
	}

	var result []byte
	operation := func() error {
		res, err := ethClient.CallContract(context.Background(), ethereum.CallMsg{
			To:   &contract,
			Data: callData,
		}, nil)
		if err != nil {
			return err
		}
		result = res
		return nil
	}
	err = utils.RetryOperation(operation)
	if err != nil {
		return "", err
	}

	// decode result
	var tokenURI string
	err = contracts.AbiMarketplace.UnpackIntoInterface(&tokenURI, "tokenURI", result)
	if err != nil {
		return "", err
	}

	return tokenURI, nil
}
