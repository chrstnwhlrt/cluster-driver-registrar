# Copyright 2017 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

.PHONY: all cluster-driver-registrar clean test

REGISTRY_NAME=christianwohlert
IMAGE_NAME=csi-cluster-driver-registrar
IMAGE_VERSION=v1.0-canary
IMAGE_TAG=$(REGISTRY_NAME)/$(IMAGE_NAME):$(IMAGE_VERSION)

REV=$(shell git describe --long --tags --match='v*' --dirty)

ifdef V
TESTARGS = -v -args -alsologtostderr -v 5
else
TESTARGS =
endif


all: cluster-driver-registrar

cluster-driver-registrar:
	mkdir -p bin
	CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -a -ldflags '-X main.version=$(REV) -extldflags "-static"' -o ./bin/cluster-driver-registrar ./cmd/cluster-driver-registrar

clean:
	rm -rf bin

container: cluster-driver-registrar
	docker build -t $(IMAGE_TAG) .

push: container
	docker push $(IMAGE_TAG)

test:
	go test `go list ./... | grep -v 'vendor'` $(TESTARGS)
	go vet `go list ./... | grep -v vendor`
