import requests

url = "http://localhost:8001/analyze"

# Using a dummy text file renamed to fake image to test payload constraints initially.
# Or better, create a tiny valid image in code.
from PIL import Image
import io

img = Image.new('RGB', (100, 100), color = 'red')
img_byte_arr = io.BytesIO()
img.save(img_byte_arr, format='JPEG')
img_byte_arr = img_byte_arr.getvalue()

files = {'file': ('test.jpg', img_byte_arr, 'image/jpeg')}

try:
    response = requests.post(url, files=files)
    print("Status Code:", response.status_code)
    print("Response JSON:", response.text)
except Exception as e:
    print(e)
