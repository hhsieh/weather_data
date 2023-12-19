
import json
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

driver = webdriver.Firefox()

# Navigate to the website
driver.get("https://builder.rcc-acis.org")

# Find StnMetaand click the 'Submit' button
StnMeta_button = driver.find_element(By.XPATH, '//button[text()="StnMeta"]')
StnMeta_button.click()

# Find input elements by ID
state_input = driver.find_element(By.ID, "state")
county_input = driver.find_element(By.ID, "county")

# Fill in the input fields
state_input.send_keys("MI")
county_input.send_keys("015")

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
    with open("Barry_County_metadata.json", "w") as json_file:
        json.dump(json_data, json_file, indent=2)

    print("JSON data found and saved.")
except Exception as e:
    print(f"Error: {e}")

# Close the browser
driver.quit()

