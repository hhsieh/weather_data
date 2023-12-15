import json
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

driver = webdriver.Firefox()

# Navigate to the website
driver.get("https://builder.rcc-acis.org")

# Find input elements by ID
sid_input = driver.find_element(By.ID, "sid")
elems_input = driver.find_element(By.ID, "elems")
sdate_input = driver.find_element(By.ID, "sdate")
edate_input = driver.find_element(By.ID, "edate")

# Fill in the input fields
sid_input.send_keys("14742")
elems_input.send_keys("4")
sdate_input.send_keys("2023-11-03")
edate_input.send_keys("2023-11-05")

# Find and click the 'Submit' button
submit_button = driver.find_element(By.XPATH, '//button[text()="Submit"]')
submit_button.click()

# Explicitly wait for the presence of JSON data
try:
    json_div = WebDriverWait(driver, 20).until(
        EC.presence_of_element_located((By.XPATH, '//pre[contains(text(), "{") and contains(text(), "}")]'))
    )

    # Extract JSON text from the div element
    json_text = json_div.text.strip()

    # Parse JSON
    json_data = json.loads(json_text)

    # Save JSON data to a file
    with open("output_3.json", "w") as json_file:
        json.dump(json_data, json_file, indent=2)

    print("JSON data found and saved.")
except Exception as e:
    print(f"Error: {e}")

# Close the browser
driver.quit()

