import aiohttp


_client_session: aiohttp.ClientSession | None = None


def init_client_session() -> None:
    """
    Initialize the client session.
    """
    global _client_session
    if _client_session is None:
        _client_session = aiohttp.ClientSession()


async def close_client_session() -> None:
    """
    Close the client session.
    """
    global _client_session
    if _client_session is not None:
        await _client_session.close()
        _client_session = None


def get_client_session() -> aiohttp.ClientSession:
    """
    Get the client session.
    """
    global _client_session
    if _client_session is None:
        init_client_session()

    if not _client_session:
        raise RuntimeError("Client session is not initialized")

    return _client_session
