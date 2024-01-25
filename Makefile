.PHONY: clean

.DEFAULT_GOAL := clipper2-wasm/dist

clipper2/CPP/tests/googletest:
	mkdir clipper2/CPP/tests/googletest
	curl -L https://github.com/google/googletest/archive/6a5938233b6519ba99ddb7c7314d45d3fa877969.tar.gz | \
		tar xz --strip=1 --directory clipper2/CPP/tests/googletest

clipper2/CPP/build:
	mkdir clipper2/CPP/build

clipper2/CPP/build/Makefile: clipper2/CPP/build clipper2/CPP/tests/googletest
	docker run \
		--rm \
		-v $(PWD):/src \
		-w /src/clipper2/CPP/build \
		--platform linux/amd64 \
		emscripten/emsdk \
			emcmake cmake ../ \
				-DCMAKE_BUILD_TYPE=Release \
				-DCMAKE_CXX_FLAGS_RELEASE="-O3" \
				-DCLIPPER2_HI_PRECISION=OFF

clipper2/CPP/build/libClipper2Z.a clipper2/CPP/build/libClipper2Zutils.a: clipper2/CPP/build/Makefile
	docker run \
		--rm \
		-v $(PWD):/src \
		--platform linux/amd64 \
		-w /src/clipper2/CPP/build \
		emscripten/emsdk \
			emmake make

clipper2-wasm/dist: clipper2/CPP/build/libClipper2.a clipper2/CPP/build/libClipper2Z.a
	docker run \
		--rm \
		-v $(PWD):/src \
		--platform linux/amd64 \
		-w /src \
		--entrypoint /src/clipper2-wasm/compile-wasm.sh \
		emscripten/emsdk \
			prod

clean:
	rm -rf clipper2/CPP/build clipper2/CPP/tests/googletest clipper2-wasm/dist
