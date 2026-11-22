"""One-time setup: creates the `sahti` database and a dedicated `sahti` user.

Uses MYSQL_ROOT_PASSWORD from .env once, then writes a random password for the
`sahti` user into .env (DB_PASSWORD) and clears the root password line.
"""
import secrets
from pathlib import Path

import pymysql
from dotenv import dotenv_values

ROOT = Path(__file__).resolve().parent.parent
ENV_PATH = ROOT / ".env"
SCHEMA_PATH = ROOT / "sql" / "schema.sql"


def main() -> None:
    env = dotenv_values(ENV_PATH)
    host = env.get("DB_HOST") or "localhost"
    port = int(env.get("DB_PORT") or 3306)
    db_name = env.get("DB_NAME") or "sahti"
    db_user = env.get("DB_USER") or "sahti"
    root_pw = env.get("MYSQL_ROOT_PASSWORD")
    user_pw = env.get("DB_PASSWORD")
    if not root_pw and db_user == "root" and user_pw:
        # Root credentials were put in DB_USER/DB_PASSWORD: use them once.
        root_pw, user_pw = user_pw, None
    if db_user == "root":
        db_user = "sahti"
    if not root_pw:
        raise SystemExit("Remplis MYSQL_ROOT_PASSWORD dans .env puis relance.")

    user_pw = user_pw or secrets.token_urlsafe(24)

    conn = pymysql.connect(host=host, port=port, user="root", password=root_pw, charset="utf8mb4")
    with conn.cursor() as cur:
        cur.execute(f"CREATE DATABASE IF NOT EXISTS `{db_name}` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci")
        cur.execute("CREATE USER IF NOT EXISTS %s@'localhost' IDENTIFIED BY %s", (db_user, user_pw))
        cur.execute("ALTER USER %s@'localhost' IDENTIFIED BY %s", (db_user, user_pw))
        cur.execute(f"GRANT ALL PRIVILEGES ON `{db_name}`.* TO %s@'localhost'", (db_user,))
        cur.execute("FLUSH PRIVILEGES")
    conn.commit()
    conn.close()

    # Apply schema as the dedicated user.
    conn = pymysql.connect(host=host, port=port, user=db_user, password=user_pw, database=db_name, charset="utf8mb4")
    sql = SCHEMA_PATH.read_text(encoding="utf-8")
    with conn.cursor() as cur:
        for stmt in [s.strip() for s in sql.split(";") if s.strip()]:
            lines = [l for l in stmt.splitlines() if not l.strip().startswith("--")]
            if "".join(lines).strip():
                cur.execute("\n".join(lines))
        cur.execute("SHOW TABLES")
        tables = [r[0] for r in cur.fetchall()]
    conn.commit()
    conn.close()

    # Rewrite .env: store sahti password, drop root password.
    out = []
    for line in ENV_PATH.read_text(encoding="utf-8").splitlines():
        if line.startswith("MYSQL_ROOT_PASSWORD="):
            out.append("MYSQL_ROOT_PASSWORD=")
        elif line.startswith("DB_USER="):
            out.append(f"DB_USER={db_user}")
        elif line.startswith("DB_PASSWORD="):
            out.append(f"DB_PASSWORD={user_pw}")
        else:
            out.append(line)
    ENV_PATH.write_text("\n".join(out) + "\n", encoding="utf-8")

    print(f"OK: base `{db_name}`, utilisateur `{db_user}`, tables: {', '.join(tables)}")
    print("Le mot de passe root a été effacé de .env.")


if __name__ == "__main__":
    main()
