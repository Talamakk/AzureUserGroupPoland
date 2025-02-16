import azure.functions as func
import logging
import json  # Required for JSON request parsing

# Initialize the function app instance
app = func.FunctionApp()

@app.function_name(name="HttpTrigger1")
@app.route(route="hello", auth_level=func.AuthLevel.ANONYMOUS)  # Public API endpoint
def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Python HTTP trigger function processed a request.")

    name = req.params.get("name")
    if not name:
        try:
            req_body = req.get_json()
            name = req_body.get("name")
        except (ValueError, TypeError):
            name = None

    if name:
        return func.HttpResponse(f"Hello, {name}!", status_code=200)
    else:
        return func.HttpResponse(
            "Please pass a name on the query string or in the request body",
            status_code=400,
        )


# import logging
# import json
# import azure.functions as func

# app = func.FunctionApp(http_auth_level=func.AuthLevel.FUNCTION)

# def create_error_response(message, status_code):
#     return func.HttpResponse(
#         json.dumps({
#                 "status": "error",
#                 "error_message": message,
#                 "status_code": status_code
#             }),
#         status_code=status_code,
#         mimetype="application/json"
#     )

# @app.route(route="convert-to-hex")
# def convertToHex(req: func.HttpRequest) -> func.HttpResponse:
#     logging.info('Python HTTP trigger function processed a request.')
#     input_string = req.params.get('input')
#     if not input_string:
#         try:
#             req_body = req.get_json()
#         except ValueError:
#             return create_error_response("Invalid JSON in request body", 400)
#         else:
#             input_string = req_body.get('input')
#     if input_string:
#         hex_string = input_string.encode("utf-8").hex()
#         return func.HttpResponse(
#             body = json.dumps({
#                 "message": "This HTTP triggered function executed successfully.",
#                 "status_code": 200,
#                 "hex": hex_string
#             }),
#             status_code = 200,
#             mimetype="application/json"
#         )
#     else:
#         return create_error_response("Input string parameter is missing in the query string or request body", 400)