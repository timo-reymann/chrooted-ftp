## [3.0.4](https://github.com/timo-reymann/chrooted-ftp/compare/3.0.3...3.0.4) (2023-09-08)


### Bug Fixes

* Fix commented out line for preventing anonymous login ([e1b37d1](https://github.com/timo-reymann/chrooted-ftp/commit/e1b37d1b9013b47712ca1a252628e90a43822205))

## [3.0.3](https://github.com/timo-reymann/chrooted-ftp/compare/3.0.2...3.0.3) (2023-09-08)


### Bug Fixes

* Wait a while until deleting busybox ([fc8fad0](https://github.com/timo-reymann/chrooted-ftp/commit/fc8fad0d7035d462cc601a80da04f926d53a8e94))

## [3.0.2](https://github.com/timo-reymann/chrooted-ftp/compare/3.0.1...3.0.2) (2023-09-08)


### Bug Fixes

* Fix messed up git rebase ([1c9af8f](https://github.com/timo-reymann/chrooted-ftp/commit/1c9af8f2e90c69ab51545d3887460da91d2e3fb6))

## [3.0.1](https://github.com/timo-reymann/chrooted-ftp/compare/3.0.0...3.0.1) (2023-09-08)


### Bug Fixes

* **deps:** update alpine docker tag to v3.18.3 ([#31](https://github.com/timo-reymann/chrooted-ftp/issues/31)) ([976a7cc](https://github.com/timo-reymann/chrooted-ftp/commit/976a7ccf1e09df198e8ec1d6f3860f26c36a19f3))
* Fix indent ([16b4c7c](https://github.com/timo-reymann/chrooted-ftp/commit/16b4c7c6082e007b971f95aba7ea88214204b345))

## [3.0.0](https://github.com/timo-reymann/chrooted-ftp/compare/2.0.4...3.0.0) (2023-09-08)


### ⚠ BREAKING CHANGES

* Nuking the busybox after start can potentially mess with customizations.

- Strip alpine base of binaries and folders not required
- Nuke busybox after start

### Features

* Harden image ([321ae2b](https://github.com/timo-reymann/chrooted-ftp/commit/321ae2b5482bc53cd67cf498d28254f364ba3dd2))

## [2.0.4](https://github.com/timo-reymann/chrooted-ftp/compare/2.0.3...2.0.4) (2023-09-04)


### Bug Fixes

* **#27:** Add indentation to config files ([#28](https://github.com/timo-reymann/chrooted-ftp/issues/28)) ([988be70](https://github.com/timo-reymann/chrooted-ftp/commit/988be7066aed0337f7b54fcea44242a077f5a311)), closes [#27](https://github.com/timo-reymann/chrooted-ftp/issues/27)

## [2.0.3](https://github.com/timo-reymann/chrooted-ftp/compare/2.0.2...2.0.3) (2023-06-15)


### Bug Fixes

* **deps:** update alpine docker tag to v3.18.2 ([#25](https://github.com/timo-reymann/chrooted-ftp/issues/25)) ([7d0abe7](https://github.com/timo-reymann/chrooted-ftp/commit/7d0abe7812a16ed297d07c9d17cd1670dee480b0))

## [2.0.2](https://github.com/timo-reymann/chrooted-ftp/compare/2.0.1...2.0.2) (2022-12-06)


### Bug Fixes

* Trigger release ([05c4e53](https://github.com/timo-reymann/chrooted-ftp/commit/05c4e53290817dac003431ba12ca2425bc621c54))

## [2.0.1](https://github.com/timo-reymann/chrooted-ftp/compare/2.0.0...2.0.1) (2022-12-06)


### Bug Fixes

* **deps:** update alpine docker tag to v3.16.3 ([#17](https://github.com/timo-reymann/chrooted-ftp/issues/17)) ([0c6e54b](https://github.com/timo-reymann/chrooted-ftp/commit/0c6e54b0d486a25a5382946cf0b82d79d0c4c8b6))
