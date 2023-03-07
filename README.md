# cucm-device-user-did-report
Powershell script to break down device, users, and DIDs from Cisco Call Manager exports on a per location (device pool) basis. This assumes Line1 is the primary DN and does not check other lines. Does not report on shared DNs. Assumes 1 route partition for all DNs.


This script was made for getting a rough estimate of User Vs Common Area Phone (CAP) when considering a move from Cisco Call Manager to Microsoft Teams with Operator Connect.

This script requires 2 exported files from CUCM, 1. all devices and 2. all translation patterns. 

For device export:

* To obtain the list of all devices, in CUCM CM Administration, navigate to "Bulk Administration" > "Phones" > "Export Phones" > "All Details"

* Export "All Phone Types" and select "Run Immediately". Name the "File Name" and "Job Description" so you can recognize it.

* You can check the status of this in "Bulk Administration" > "Job Scheduler". When complete, you can access the file in "Bulk Administration" > "Upload/Download Files".


For translation pattern export:

* To obtain the list of all devices, in CUCM CM Administration, navigate to "Bulk Administration" > "Import/Export" > "Export"

* Name the "File Name" and "Job Description" so you can recognize it.

* Select the "Translation Pattern" box under the "Call Routing Data" section.

* You can check the status of this in "Bulk Administration" > "Job Scheduler". When complete, you can access the file in "Bulk Administration" > "Upload/Download Files". You will need to extract the csv from the tar file once downloaded. 


Save both files where you'd like, and update the script variables for this path location.
