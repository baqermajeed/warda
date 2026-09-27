from __future__ import annotations

import time
from threading import Lock
from typing import Any

from app.config import settings

_memory: dict[str, tuple[float, str]] = {}
_lock = Lock()
_redis = None


def _get_redis():
    global _redis
    if _redis is not None:
        return _redis
    if not settings.redis_url:
        return None
    try:
        import redis

        client = redis.Redis.from_url(settings.redis_url, decode_responses=True)
        client.ping()
        _redis = client
        return _redis
    except Exception:
        return None


def cache_get(key: str) -> str | None:
    client = _get_redis()
    if client is not None:
        try:
            return client.get(key)
        except Exception:
            pass
    with _lock:
        item = _memory.get(key)
        if not item:
            return None
        expires_at, value = item
        if expires_at < time.time():
            _memory.pop(key, None)
            return None
        return value


def cache_set(key: str, value: str, ttl_seconds: int) -> None:
    client = _get_redis()
    if client is not None:
        try:
            client.setex(key, ttl_seconds, value)
            return
        except Exception:
            pass
    with _lock:
        _memory[key] = (time.time() + ttl_seconds, value)


def cache_delete(key: str) -> None:
    client = _get_redis()
    if client is not None:
        try:
            client.delete(key)
        except Exception:
            pass
    with _lock:
        _memory.pop(key, None)


def incr_with_ttl(key: str, ttl_seconds: int) -> int:
    """Increment a counter that expires after ttl_seconds (from first hit)."""
    client = _get_redis()
    if client is not None:
        try:
            pipe = client.pipeline()
            pipe.incr(key)
            pipe.expire(key, ttl_seconds, nx=True)
            count, _ = pipe.execute()
            return int(count)
        except Exception:
            pass
    with _lock:
        now = time.time()
        item = _memory.get(key)
        if not item or item[0] < now:
            _memory[key] = (now + ttl_seconds, "1")
            return 1
        count = int(item[1]) + 1
        _memory[key] = (item[0], str(count))
        return count


def redis_ok() -> bool:
    client = _get_redis()
    if client is None:
        return False
    try:
        client.ping()
        return True
    except Exception:
        return False


def cache_json_get(key: str) -> Any | None:
    import json

    raw = cache_get(key)
    if raw is None:
        return None
    try:
        return json.loads(raw)
    except Exception:
        return None


def cache_json_set(key: str, value: Any, ttl_seconds: int) -> None:
    import json

    cache_set(key, json.dumps(value, ensure_ascii=False), ttl_seconds)
