from ftplib import FTP
from pathlib import Path

import paramiko
import pytest
from testcontainers.core.container import DockerContainer
from testcontainers.core.image import DockerImage
from testcontainers.core.waiting_utils import wait_for_logs


@pytest.fixture(scope="session")
def docker_image():
    image = DockerImage(path=Path(__file__).parent.parent, tag="timoreymann/chrooted-ftp:local-test-image")
    image.build()
    return image


@pytest.fixture
def chrooted_ftp_test_container(docker_image) -> DockerContainer:
    container = DockerContainer(docker_image.tag)
    container.with_exposed_ports(21)
    container.with_exposed_ports(2022)

    return container


@pytest.fixture(scope="session")
def create_ftp_connection():

    def impl(port: str | int, username: str, password: str):
        ftp = FTP()
        ftp.connect(host="localhost", port=int(port))
        ftp.login(username, password)
        return ftp

    return impl


@pytest.fixture(scope="session")
def create_sftp_connection():
    def impl(port, username, password) -> paramiko.SFTPClient:
        ssh_client = paramiko.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh_client.connect("localhost", port, username, password)
        return ssh_client.open_sftp()

    return impl


@pytest.fixture(scope="session")
def verify_login(create_ftp_connection, create_sftp_connection):
    def impl(chrooted_ftp_test_container, connection_type, password, username):
        if connection_type == "ftp":
            ftp_port = chrooted_ftp_test_container.get_exposed_port(21)
            ftp = create_ftp_connection(ftp_port, username, password)
            assert ftp.getwelcome() is not None
        elif connection_type == "sftp":
            sftp_port = chrooted_ftp_test_container.get_exposed_port(2022)
            sftp = create_sftp_connection(sftp_port, username, password)
            result = sftp.listdir()
            assert result is not None

    return impl


@pytest.fixture(scope="session")
def wait_for_container_to_be_started():
    def impl(container):
        wait_for_logs(container, "Server listening on :: port 2022")

    return impl
