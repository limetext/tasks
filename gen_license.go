// Copyright 2013 The lime Authors.
// Use of this source code is governed by a 2-clause
// BSD-style license that can be found in the LICENSE file.

package main

import (
	"bytes"
	"errors"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"strconv"
	"time"
)

var (
	year          = strconv.FormatInt(int64(time.Now().Year()), 10)
	licenseheader = []byte(`// Copyright ` + year + ` The lime Authors.
// Use of this source code is governed by a 2-clause
// BSD-style license that can be found in the LICENSE file.
`)
)

func license(path string, fi os.FileInfo, err error) error {
	if fi.IsDir() {
		switch filepath.Base(path) {
		case "testdata":
			return filepath.SkipDir
		case "vendor":
			return filepath.SkipDir
		}
		return nil
	}

	switch filepath.Ext(path) {
	case ".go":
	default:
		return nil
	}

	changed := false
	cmp, err := ioutil.ReadFile(path)
	if err != nil {
		return err
	}
	lhn := append(licenseheader, '\n')
	if !bytes.Equal([]byte("// Copyright"), cmp[:12]) {
		cmp = append(lhn, cmp...)
		changed = true
	}

	if changed {
		if *check {
			return errors.New(fmt.Sprintf("Missing license in %s", path))
		}
		log.Println("Added license to", path)
		return ioutil.WriteFile(path, cmp, fi.Mode().Perm())
	}

	return nil
}

var (
	scan  = flag.String("scan", "./", "set scan path")
	check = flag.Bool("check", false, "just check if all files have license")
)

func main() {
	flag.Parse()
	if err := filepath.Walk(*scan, license); err != nil {
		log.Fatal(err)
	}
}
