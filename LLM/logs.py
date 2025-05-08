import os
from pathlib import Path
from datetime import datetime
import logging
import sys


def setup_new_logfile() -> Path:
    """
    Set up a new log file with the current date and time.
    """
    log_dir = os.environ.get("LOG_DIR", "logs")
    log_dir = Path(log_dir)

    # Create logs directory if it doesn't exist
    if not log_dir.exists():
        log_dir.mkdir(parents=True, exist_ok=True)

    # Create a new log file with the current date and time
    file_name = f"log_{datetime.now().strftime('%Y-%m-%d')}.txt"
    log_file = log_dir / file_name

    with open(log_file, "a") as f:
        f.write("Log file created.\n")

    return log_file


def setup_logging() -> None:
    """
    Set up logging to both a file and the console (stderr).
    """
    log_file = setup_new_logfile()
    log_level = logging.DEBUG

    # Get the root logger
    logger = logging.getLogger()
    logger.setLevel(log_level)

    # Remove existing handlers if basicConfig was called elsewhere
    # or to prevent duplicate logs if this function is called multiple times
    # Be cautious if other libraries rely on default handlers
    # for handler in logger.handlers[:]:
    #    logger.removeHandler(handler)

    # Create formatter
    formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(name)s - %(message)s")

    # File Handler
    file_handler = logging.FileHandler(log_file)
    file_handler.setLevel(logging.DEBUG)
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)

    # Console (Stream) Handler
    stream_handler = logging.StreamHandler(sys.stderr)
    stream_handler.setLevel(log_level)
    stream_handler.setFormatter(formatter)
    logger.addHandler(stream_handler)

    # Prevent propagation to avoid potential duplicate logging if root is already configured
    # logger.propagate = False

    logging.info(f"Logging configured. Level: {logging.getLevelName(log_level)}. Outputting to file: {log_file} and console.")
