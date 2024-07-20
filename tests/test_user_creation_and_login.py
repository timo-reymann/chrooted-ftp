import tempfile

import pytest
from testcontainers.core.waiting_utils import wait_for_logs


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
        chrooted_ftp_test_container,
        verify_login,
        username,
        password,
        connection_type
):
    chrooted_ftp_test_container.with_env(f"ACCOUNT_{username}", password)
    with chrooted_ftp_test_container:
        wait_for_logs(chrooted_ftp_test_container, "Server listening on :: port 2022")

        verify_login(chrooted_ftp_test_container, connection_type, password, username)


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
        chrooted_ftp_test_container,
        username,
        password,
        connection_type,
        verify_login,
):
    with tempfile.NamedTemporaryFile() as f:
        f.write(f"{username}:{password}\n".encode("utf8"))
        f.flush()
        chrooted_ftp_test_container.with_volume_mapping(f.name, "/opt/chrooted-ftp/users")
        with chrooted_ftp_test_container:
            wait_for_logs(chrooted_ftp_test_container, "Server listening on :: port 2022")

            verify_login(chrooted_ftp_test_container, connection_type, password, username)
