from flask import Flask, jsonify, request

app = Flask(__name__)

@app.route('/api/example', methods=['GET'])
def example_endpoint():
    return jsonify({"message": "This is an example endpoint."})

@app.route('/api/data', methods=['POST'])
def data_endpoint():
    data = request.json
    return jsonify({"received": data}), 201

if __name__ == '__main__':
    app.run(debug=True)