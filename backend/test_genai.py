from google import genai
from google.genai import types
from PIL import Image

image = Image.new('RGB', (100, 100), color = 'red')

print(dir(types.Part))
try:
    part = types.Part.from_image(image)
    print("from_image works")
except Exception as e:
    print("from_image error:", e)

try:
    part = types.Part.from_bytes(data=b'hello', mime_type='image/jpeg')
    print("from_bytes works")
except Exception as e:
    print("from_bytes error:", e)

try:
    client = genai.Client(api_key="dummy")
    # New SDK just takes the PIL image directly in the contents list.
    print("Checking if Client exists:", type(client))
except Exception as e:
    print("Client error:", e)
