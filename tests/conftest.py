import importlib.util
import pytest


def has(mod):
    return importlib.util.find_spec(mod) is not None


def pytest_ignore_collect(path, config):

    p = str(path)

    # Always skip heavy / enterprise-only tests in demo
    skip_paths = [
        "tests/integration",
        "tests/benchmarks",
        "tests/test_temporal.py",
        "tests/test_worm.py",
    ]

    for s in skip_paths:
        if s in p:
            return True

    return False


def pytest_collection_modifyitems(config, items):

    skip = pytest.mark.skip(
        reason="Enterprise dependency not present in demo build"
    )

    for item in items:

        if "galani" in item.nodeid and not has("galani"):
            item.add_marker(skip)

        if "temporal" in item.nodeid and not has("temporalio"):
            item.add_marker(skip)

        if "asyncpg" in item.nodeid and not has("asyncpg"):
            item.add_marker(skip)
