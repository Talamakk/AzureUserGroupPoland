import azure.functions as func
import logging
import json  # Required for JSON request parsing

# Initialize the function app instance
app = func.FunctionApp()

@app.function_name(name="public_function")
@app.route(route="public_function", auth_level=func.AuthLevel.ANONYMOUS)  # Public API endpoint
def public_function(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Python HTTP trigger function processed a request.")

    name = req.params.get("name")
    if not name:
        try:
            req_body = req.get_json()
            name = req_body.get("name")
        except (ValueError, TypeError):
            name = None

    if name:
        return func.HttpResponse(
            f"Hello, {name}!\nIt's a publicly exposed function here!",
            status_code=200
        )
    else:
        return func.HttpResponse(
            "Please pass a name on the query string or in the request body",
            status_code=400,
        )

@app.function_name(name="secure_function")
@app.route(route="secure_function", auth_level=func.AuthLevel.FUNCTION)  # Requires API Key
def secure_function(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Secure function processed a request.")

    name = req.params.get("name")
    if not name:
        try:
            req_body = req.get_json()
            name = req_body.get("name")
        except (ValueError, TypeError):
            name = None

    if name:
        return func.HttpResponse(
            f"Hello, {name}!\nIt's a secure function here!",
            status_code=200
        )
    else:
        return func.HttpResponse(
            "Please pass a name on the query string or in the request body",
            status_code=400,
        )

@app.function_name(name="secure_function2")
@app.route(route="secure_function2", auth_level=func.AuthLevel.FUNCTION)  # Requires API Key
def secure_function(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Secure function processed a request.")

    name = req.params.get("name")
    if not name:
        try:
            req_body = req.get_json()
            name = req_body.get("name")
        except (ValueError, TypeError):
            name = None

    if name:
        return func.HttpResponse(
            f"Hello, {name}!\nIt's a secure function number 2 here!",
            status_code=200
        )
    else:
        return func.HttpResponse(
            "Please pass a name on the query string or in the request body",
            status_code=400,
        )