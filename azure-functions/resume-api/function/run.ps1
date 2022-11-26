
using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-host "HTTP trigger fired."

# Resume data in JSON
$resumeOutput = @"
{    
    "basics": {
      "name": "City Hallin",
      "label": "Cloud Engineer",
      "image": "",
      "email": "cityh.hallin@mail.com",
      "phone": "(555) 555-5555",
      "url": "",
      "summary": "This is a sample resume for the Resume API repo.",
      "location": {
        "address": "271 Main St",
        "postalCode": "CA 55555",
        "city": "San Francisco",
        "countryCode": "US",
        "region": "California"
      },
      "profiles": [
        {
          "network": "Github",
          "username": "CityHallin",
          "url": "https://github.com/CityHallin"
        }
      ]
    },
    "work": [
      {
        "name": "Cloud Sample Company",
        "location": "Palo Alto, CA",
        "description": "",
        "position": "Sr. Cloud Engineer",
        "url": "https://cloudsamplecompany.fakecompany.com",
        "startDate": "2020-12-01",
        "endDate": "Present",        
        "highlights": [
          "Primary administrator for cloud platforms",
          "Escalation point for advanced issues",
          "Managed IaaS, PaaS, and other serverless resources in the cloud"
        ]
      }
    ],
    "volunteer": [
      {
        "organization": "",
        "position": "",
        "url": "",
        "startDate": "",
        "endDate": "",
        "summary": "",
        "highlights": [
          "",
          ""
        ]
      }
    ],
    "education": [
      {
        "institution": "University of Mars",
        "url": "https://www.mars.notearth.edu/",
        "area": "Information Technology",
        "studyType": "Bachelor",
        "startDate": "2016-06-01",
        "endDate": "2020-01-01",
        "score": "4.0",
        "courses": [
          "SA200 - Systems Administration",
          "SC300 - IT Security"
        ]
      }
    ],
    "awards": [
      {
        "title": "",
        "date": "",
        "awarder": "",
        "summary": ""
      }
    ],
    "publications": [
      {
        "name": "",
        "publisher": "",
        "releaseDate": "",
        "url": "",
        "summary": ""
      }
    ],
    "skills": [
      {
        "name": "",
        "level": "",
        "keywords": [
          "",
          ""
        ]
      }      
    ],
    "languages": [
      {
        "language": "English",
        "fluency": "Native speaker"
      }
    ],
    "interests": [
      {
        "name": "Photography",
        "keywords": [
          "wildlife",
          "nature"
        ]
      }
    ],
    "references": [
      {
        "name": "Firstname Lastname",
        "reference": "Add written comment reference from individual. Do not post reference contact information in API out of respect for references."
      }
    ],
    "projects": [
      {
        "name": "Hypervisor Migration",
        "description": "MIgrated 200 VMs from VMware to Hyper-V cluster",
        "highlights": [
          "Did not cause any business downtime",
          "Saved money on license costs",
          "Upgraded hosting hardware"
        ],
        "keywords": [
          "VMware", "Hyper-V"
        ],
        "startDate": "2022-01-24",
        "endDate": "2022-03-15",
        "url": "missdirection.example.com",
        "roles": [
          "Team lead", "Designer"
        ]        
      }
    ]
  }
"@

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $resumeOutput
})
