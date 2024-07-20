import pytest
from testcontainers.core.container import DockerContainer
from testcontainers.core.image import DockerImage


@pytest.fixture(scope="session")
def docker_image():
    image = DockerImage(path="..", tag="timoreymann/chrooted-ftp:local-test-image")
    image.build()
    return image


@pytest.fixture
def chrooted_ftp_test_container(docker_image) -> DockerContainer:
    container = DockerContainer(docker_image.tag)
    container.with_exposed_ports(21)
    container.with_exposed_ports(2022)

    return container
