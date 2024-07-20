import tempfile

import pytest


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
        wait_for_container_to_be_started,
        username,
        password,
        connection_type
):
    chrooted_ftp_test_container.with_env(f"ACCOUNT_{username}", password)
    with chrooted_ftp_test_container:
        wait_for_container_to_be_started(chrooted_ftp_test_container)
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
        wait_for_container_to_be_started,
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
            wait_for_container_to_be_started(chrooted_ftp_test_container)
            verify_login(chrooted_ftp_test_container, connection_type, password, username)
