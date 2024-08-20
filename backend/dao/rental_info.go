package dao

import "dephy-conduits/model"

func CreateRentalInfo(rentalInfo *model.RentalInfo) error {
	return db.Create(rentalInfo).Error
}

func UpdateRentalInfo(rentalInfo *model.RentalInfo) error {
	return db.Save(rentalInfo).Error
}

func UpdateRentalStatus(chainId uint64, device string, newStatus model.ListingStatus) error {
	return db.Model(&model.RentalInfo{}).
		Where("chain_id = ? AND device = ?", chainId, device).
		Order("block_number DESC").
		Limit(1).
		Update("rental_status", newStatus).Error
}

func GetCurrentRentalInfoByDevice(chainId uint64, device string) (*model.RentalInfo, error) {
	var rentalInfo model.RentalInfo
	err := db.Where("chain_id = ? AND device = ?", chainId, device).
		Order("block_number DESC").
		First(&rentalInfo).Error
	if err != nil {
		return nil, err
	}
	return &rentalInfo, nil
}

func GetCurrentRentalInfoByInstanceId(chainId uint64, instanceId string) (*model.RentalInfo, error) {
	var rentalInfo model.RentalInfo
	err := db.Where("chain_id = ? AND instance_id = ?", chainId, instanceId).
		Order("block_number DESC").
		First(&rentalInfo).Error
	if err != nil {
		return nil, err
	}
	return &rentalInfo, nil
}
