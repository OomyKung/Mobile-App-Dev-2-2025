from flask import Flask, render_template, request, redirect, jsonify
from flaskext.mysql import MySQL

app = Flask(__name__)
mysql = MySQL()

# ====== MySQL config (แก้ user/pass ให้ตรงเครื่องคุณ) ======
app.config["MYSQL_DATABASE_HOST"] = "localhost"
app.config["MYSQL_DATABASE_USER"] = "root"
app.config["MYSQL_DATABASE_PASSWORD"] = ""   # XAMPP ปกติเป็นค่าว่าง
app.config["MYSQL_DATABASE_DB"] = "emp"

mysql.init_app(app)

def get_conn():
    return mysql.connect()

# =========================
#   WEB GUI (HTML)
# =========================
@app.route("/")
def index():
    return render_template("index.html")

@app.route("/addnew")
def addnew():
    return render_template("add.html")

@app.route("/addrec", methods=["POST"])
def addrec():
    name = request.form.get("name")
    email = request.form.get("email")
    phone = request.form.get("phone")
    address = request.form.get("address")
    age = request.form.get("age")  # อาจเป็น "" ได้
    major = request.form.get("major")

    # แปลง age ถ้าเป็นค่าว่าง
    age_val = None
    try:
        age_val = int(age) if age not in (None, "") else None
    except:
        age_val = None

    conn = get_conn()
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO emp(name,email,phone,address,age,major) VALUES (%s,%s,%s,%s,%s,%s)",
        (name, email, phone, address, age_val, major),
    )
    conn.commit()
    cur.close()
    conn.close()

    return redirect("/emp")

# =========================
#   REST API (สำหรับ Flutter)
# =========================

@app.route("/emp", methods=["GET"])
def api_get_all():
    conn = get_conn()
    cur = conn.cursor()
    cur.execute("SELECT id, name, email, phone, address, age, major FROM emp")
    rows = cur.fetchall()
    cur.close()
    conn.close()

    data = []
    for r in rows:
        data.append({
            "id": r[0],
            "name": r[1],
            "email": r[2],
            "phone": r[3],
            "address": r[4],
            "age": r[5],
            "major": r[6],
        })

    return jsonify(data)

@app.route("/create", methods=["POST"])
def api_create():
    payload = request.get_json(force=True)

    name = payload.get("name", "")
    email = payload.get("email", "")
    phone = payload.get("phone", "")
    address = payload.get("address", "")
    major = payload.get("major", "")

    age = payload.get("age", None)
    age_val = None
    try:
        age_val = int(age) if age is not None else None
    except:
        age_val = None

    conn = get_conn()
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO emp(name,email,phone,address,age,major) VALUES (%s,%s,%s,%s,%s,%s)",
        (name, email, phone, address, age_val, major),
    )
    conn.commit()
    cur.close()
    conn.close()

    return jsonify({"status": "success"})

@app.route("/update/<int:emp_id>", methods=["PUT"])
def api_update(emp_id):
    payload = request.get_json(force=True)

    name = payload.get("name", "")
    email = payload.get("email", "")
    phone = payload.get("phone", "")
    address = payload.get("address", "")
    major = payload.get("major", "")

    age = payload.get("age", None)
    age_val = None
    try:
        age_val = int(age) if age is not None else None
    except:
        age_val = None

    conn = get_conn()
    cur = conn.cursor()
    cur.execute(
        "UPDATE emp SET name=%s,email=%s,phone=%s,address=%s,age=%s,major=%s WHERE id=%s",
        (name, email, phone, address, age_val, major, emp_id),
    )
    conn.commit()
    cur.close()
    conn.close()

    return jsonify({"status": "success"})

@app.route("/delete/<int:emp_id>", methods=["DELETE"])
def api_delete(emp_id):
    conn = get_conn()
    cur = conn.cursor()
    cur.execute("DELETE FROM emp WHERE id=%s", (emp_id,))
    conn.commit()
    cur.close()
    conn.close()

    return jsonify({"status": "success"})

# ====== Run (พอร์ต 10000) ======
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=10000, debug=True)
