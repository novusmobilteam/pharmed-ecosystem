enum DrawerPhysicalStatus {
  locked, // h0, h4, h5
  waitingPull, // h1
  fullyOpen, // h3, h6 (İşlem yapılabilir)
  halfOpen, // h2
  unknown, // Tanımsız
  timeoutError,
}
