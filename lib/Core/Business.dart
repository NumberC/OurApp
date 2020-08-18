class Business {
  double pricePerMile = 4.3;
  double minimumPrice = 5;

  double getPrice(double miles) {
    double normalPrice = pricePerMile * miles;
    return (normalPrice > minimumPrice) ? normalPrice : minimumPrice;
  }
}
