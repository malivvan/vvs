name: build

on: [push]

jobs:
  build:
    name: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Go
        uses: actions/setup-go@v5
        with:
          go-version: '1.22.5'
      - name: Install dependencies
        run: go get .
      - name: Build
        env:
          SIGNING_KEY: ${{ secrets.SIGNING_KEY }}
          SIGNING_KEY: ${{ secrets.SIGNING_SEC }}
          SIGNING_PUB: ${{ vars.SIGNING_PUB }}
        run: make
      - uses: actions/upload-artifact@v4
        with:
          name: vvs
          path: build/vvs_*
