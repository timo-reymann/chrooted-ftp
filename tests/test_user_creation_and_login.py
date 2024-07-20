import tempfile
from ftplib import FTP

import paramiko
import pytest
from testcontainers.core.waiting_utils import wait_for_logs


def verify_login(chrooted_ftp_test_container, connection_type, create_ftp_connection, password, username):
    if connection_type == "ftp":
        ftp_port = chrooted_ftp_test_container.get_exposed_port(21)
        ftp_connection = create_ftp_connection(ftp_port)
        ftp_connection.login(username, password)
    elif connection_type == "sftp":
        sftp_port = chrooted_ftp_test_container.get_exposed_port(2022)
        ssh_client = paramiko.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh_client.connect("localhost", sftp_port, username, password)
        sftp = ssh_client.open_sftp()
        sftp.listdir()


@pytest.fixture
def create_ftp_connection():
    def impl(port: str | int):
        ftp = FTP()
        ftp.connect(host="localhost", port=int(port))
        return ftp

    return impl


@pytest.mark.parametrize(
    [
        "username",
        "password"
    ], [
        [
            "user", "password",
        ],
        [
            "alex", "sp3ci$al^",
        ]
    ]
)
@pytest.mark.parametrize("connection_type", ["sftp", "ftp"])
def test_login_with_env_var_user(
        chrooted_ftp_test_container, create_ftp_connection, username, password, connection_type
):
    chrooted_ftp_test_container.with_env(f"ACCOUNT_{username}", password)
    with chrooted_ftp_test_container:
        wait_for_logs(chrooted_ftp_test_container, "Server listening on :: port 2022")

        verify_login(chrooted_ftp_test_container, connection_type, create_ftp_connection, password, username)


@pytest.mark.parametrize(
    [
        "username",
        "password"
    ], [
        [
            "user", "password",
        ],
        [
            "alex", "sp3ci$al^",
        ]
    ]
)
@pytest.mark.parametrize("connection_type", ["sftp", "ftp"])
def test_login_with_file_created_user(
        chrooted_ftp_test_container, create_ftp_connection, username, password, connection_type
):
    with tempfile.NamedTemporaryFile() as f:
        f.write(f"{username}:{password}\n".encode("utf8"))
        f.flush()
        chrooted_ftp_test_container.with_volume_mapping(f.name, "/opt/chrooted-ftp/users")
        with chrooted_ftp_test_container:
            wait_for_logs(chrooted_ftp_test_container, "Server listening on :: port 2022")

            verify_login(chrooted_ftp_test_container, connection_type, create_ftp_connection, password, username)
