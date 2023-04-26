import json
import time
import requests
from msal import ConfidentialClientApplication

CLIENT_ID = ''
CLIENT_SECRET = ''
TENANT_ID = ''
USER_EMAIL = ''
SCOPE = ['https://graph.microsoft.com/.default']
AUTHORITY = f'https://login.microsoftonline.com/{TENANT_ID}'

def get_access_token(app):
    result = app.acquire_token_for_client(scopes=SCOPE)
    if 'access_token' in result:
        return result['access_token']
    else:
        return None

def get_user_id(access_token, user_email):
    headers = {'Authorization': f'Bearer {access_token}', 'Content-Type': 'application/json'}
    graph_url = f'https://graph.microsoft.com/v1.0/users?$filter=userPrincipalName eq \'{user_email}\''
    response = requests.get(graph_url, headers=headers)

    if response.status_code == 200:
        users = response.json()['value']
        if len(users) > 0:
            return users[0]['id']
        else:
            print("No user found with the specified email.")
            return None
    else:
        print(f"Error: {response.status_code}, {response.text}")
        return None

def get_messages(access_token, user_id):
    headers = {'Authorization': f'Bearer {access_token}', 'Content-Type': 'application/json'}
    graph_url = f"https://graph.microsoft.com/v1.0/users/{user_id}/messages"
    response = requests.get(graph_url, headers=headers)

    if response.status_code == 200:
        messages = response.json()["value"]
        for message in messages:
            print(f"Subject: {message['subject']}")
            print(f"From: {message['from']['emailAddress']['address']}")
            print(f"Received: {message['receivedDateTime']}")
            print("-" * 30)
    else:
        print(f"Error: {response.status_code}, {response.text}")

def get_groups(access_token):
    headers = {'Authorization': f'Bearer {access_token}', 'Content-Type': 'application/json'}
    graph_url = 'https://graph.microsoft.com/v1.0/groups'
    response = requests.get(graph_url, headers=headers)

    if response.status_code == 200:
        groups = response.json()["value"]
        return groups
    else:
        print(f"Error: {response.status_code}, {response.text}")
        return []

def get_plans(access_token, group_id):
    headers = {'Authorization': f'Bearer {access_token}', 'Content-Type': 'application/json'}
    plans_url = f'https://graph.microsoft.com/v1.0/groups/{group_id}/planner/plans'
    response = requests.get(plans_url, headers=headers)

    if response.status_code == 200:
        plans = response.json()["value"]
        return plans
    else:
        print(f"Error getting plans: {response.status_code}, {response.text}")
        return []

def get_buckets(access_token, plan_id):
    headers = {'Authorization': f'Bearer {access_token}', 'Content-Type': 'application/json'}
    buckets_url = f"https://graph.microsoft.com/v1.0/planner/plans/{plan_id}/buckets"
    response = requests.get(buckets_url, headers=headers)

    if response.status_code == 200:
        buckets = response.json()["value"]
        return buckets
    else:
        print(f"Error getting buckets: {response.status_code}, {response.text}")
        return []

def create_task(access_token, plan_id, bucket_id, task_title):
    headers = {'Authorization': f'Bearer {access_token}', 'Content-Type': 'application/json'}
    task_data = {'planId': plan_id, 'bucketId': bucket_id, 'title': task_title}
    tasks_url = 'https://graph.microsoft.com/v1.0/planner/tasks'
    response = requests.post(tasks_url, headers=headers, data=json.dumps(task_data))

    if response.status_code == 201:
        task = response.json()
        print(f"Task '{task['title']}' (ID: {task['id']}) created successfully")
    else:
        print(f"Error creating task: {response.status_code}, {response.text}")

def main():
    app = ConfidentialClientApplication(CLIENT_ID, authority=AUTHORITY, client_credential=CLIENT_SECRET)
    access_token = get_access_token(app)

    if access_token is None:
        print("Error obtaining access token.")
        return

    user_id = get_user_id(access_token, USER_EMAIL)
    if user_id is not None:
        print(f"User ID for {USER_EMAIL}: {user_id}")

        get_messages(access_token, user_id)

    groups = get_groups(access_token)
    for group in groups:
        print(f"Group name: {group['displayName']}")
        print(f"Group ID: {group['id']}")
        print("-" * 30)
        group_id = group['id']

        plans = get_plans(access_token, group_id)
        for plan in plans:
            print(f"Plan: {plan['title']} (ID: {plan['id']})")
            buckets = get_buckets(access_token, plan['id'])

            for bucket in buckets:
                print(f"Bucket: {bucket['name']} (ID: {bucket['id']})")


if __name__ == "__main__":
    main()

