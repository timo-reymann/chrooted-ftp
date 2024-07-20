from io import BytesIO
from tempfile import NamedTemporaryFile


def test_crud_sftp(
        chrooted_ftp_test_container,
        create_sftp_connection,
        wait_for_container_to_be_started,
):
    # Create account to use in test
    chrooted_ftp_test_container.with_env("ACCOUNT_pytest", "test")
    with chrooted_ftp_test_container:
        wait_for_container_to_be_started(chrooted_ftp_test_container)
        connection = create_sftp_connection(chrooted_ftp_test_container.get_exposed_port(2022), "pytest", "test")

        # Create file
        with NamedTemporaryFile() as f:
            f.write(b"hello world")
            f.flush()
            connection.put(f.name, "/data/test.txt")

        # Update file
        with NamedTemporaryFile() as f:
            f.write(b"hello new world")
            f.flush()
            connection.put(f.name, "/data/test.txt")

        # Read file
        with NamedTemporaryFile() as f:
            connection.get("/data/test.txt", f.name)
            assert f.read() == b'hello new world'

        # List files
        assert ["test.txt"] == connection.listdir("/data")

        # Delete file
        connection.remove("/data/test.txt")
        assert [] == connection.listdir("/data")


def test_crud_ftp(chrooted_ftp_test_container, create_ftp_connection, wait_for_container_to_be_started):
    # Create account to use in test
    chrooted_ftp_test_container.with_env("ACCOUNT_pytest", "test")

    # Ensure the number of passive ports are limited as we cant expose a range like in a native set up
    # this unfortunately rewrites the IP and it becomes necessary to disable the security check for passive FTP in tests
    chrooted_ftp_test_container.with_env("PASSIVE_MAX_PORT", "10091")
    chrooted_ftp_test_container.with_env("PASSIVE_PROMISCUOUS", "yes")
    chrooted_ftp_test_container.with_bind_ports(10090, 10090)
    chrooted_ftp_test_container.with_bind_ports(10091, 10091)
    with chrooted_ftp_test_container:
        wait_for_container_to_be_started(chrooted_ftp_test_container)
        connection = create_ftp_connection(chrooted_ftp_test_container.get_exposed_port(21), "pytest", "test")

        # Create file
        connection.storlines("STOR test.txt", BytesIO(b'test'))

        # Update file
        connection.storlines("STOR test.txt", BytesIO(b'updated test'))

        # Read file
        with NamedTemporaryFile() as f:
            connection.retrbinary('RETR test.txt', f.write)
            f.flush()
            f.seek(0)
            assert b'updated test\r\n' == f.read()

        # List files
        assert ['test.txt'] == connection.nlst()

        # Delete file
        connection.delete("test.txt")
        assert [] == connection.nlst()
