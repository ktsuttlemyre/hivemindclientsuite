# kqremotestatsbox


### Use remote_install 
This script will create an ssh tunnel and log in for interactive remote install


### Use install.sh if you are running from the pi itself
Note: if you run this on the pi it is expected that you have a modern browser installed on the pi in order to accept the prompt
```bash
rclone config
...etc
...etc
Remote config
Use web browser to automatically authenticate rclone with remote?
 * Say Y if the machine running rclone has a web browser you can use
 * Say N if running rclone on a (remote) machine without web browser access
If not sure try Y. If Y failed, try N.
y) Yes
n) No
y/n> y
...etc
...etc
```
otherwise use remote_install to install from a linux computer that supports ssh tunneling


### Manual creation of client/app
This is the same guide from  [Rclone make your own client_id](https://rclone.org/drive/#making-your-own-client-id) but scopes are different

When you use rclone with Google drive in its default configuration you are using rclone's client_id. This is shared between all the rclone users. There is a global rate limit on the number of queries per second that each client_id can do set by Google. rclone already has a high quota and I will continue to make sure it is high enough by contacting Google.

It is strongly recommended to use your own client ID as the default rclone ID is heavily used. If you have multiple services running, it is recommended to use an API key for each service. The default Google quota is 10 transactions per second so it is recommended to stay under that number as if you use more than that, it will cause rclone to rate limit and make things slower.

Here is how to create your own Google Drive client ID for rclone:

Log into the Google API Console with your Google account. It doesn't matter what Google account you use. (It need not be the same account as the Google Drive you want to access)

Select a project or create a new project.

Under "ENABLE APIS AND SERVICES" search for "Drive", and enable the "Google Drive API".

Click "Credentials" in the left-side panel (not "Create credentials", which opens the wizard).

If you already configured an "Oauth Consent Screen", then skip to the next step; if not, click on "CONFIGURE CONSENT SCREEN" button (near the top right corner of the right panel), then select "External" and click on "CREATE"; on the next screen, enter an "Application name" ("rclone" is OK); enter "User Support Email" (your own email is OK); enter "Developer Contact Email" (your own email is OK); then click on "Save" (all other data is optional). You will also have to add some scopes, 

`only add /auth/drive.file` 

. After adding scopes, click "Save and continue" to add test users. Be sure to add your own account to the test users. Once you've added yourself as a test user and saved the changes, click again on "Credentials" on the left panel to go back to the "Credentials" screen.

(PS: if you are a GSuite user, you could also select "Internal" instead of "External" above, but this will restrict API use to Google Workspace users in your organisation).

Click on the "+ CREATE CREDENTIALS" button at the top of the screen, then select "OAuth client ID".

Choose an application type of "Desktop app" and click "Create". (the default name is fine)

It will show you a client ID and client secret. Make a note of these.

(If you selected "External" at Step 5 continue to Step 9. If you chose "Internal" you don't need to publish and can skip straight to Step 10 but your destination drive must be part of the same Google Workspace.)

Go to "Oauth consent screen" and then click "PUBLISH APP" button and confirm. You will also want to add yourself as a test user.

Provide the noted client ID and client secret to rclone.

Be aware that, due to the "enhanced security" recently introduced by Google, you are theoretically expected to "submit your app for verification" and then wait a few weeks(!) for their response; in practice, you can go right ahead and use the client ID and client secret with rclone, the only issue will be a very scary confirmation screen shown when you connect via your browser for rclone to be able to get its token-id (but as this only happens during the remote configuration, it's not such a big deal). Keeping the application in "Testing" will work as well, but the limitation is that any grants will expire after a week, which can be annoying to refresh constantly. If, for whatever reason, a short grant time is not a problem, then keeping the application in testing mode would also be sufficient.


`ssh -L 53682:localhost:53682 -C -N -l hivemind 10.0.0.186`

###  fail2ban settings 
originally from https://gist.github.com/petarnikolovski/e24f9bfda6e1277640e376f8a2ecfaef


Use these to check if everything is all right
```bash
sudo systemctl restart fail2ban
sudo fail2ban-client status
```
Check iptables with:
```bash
sudo iptables -S
sudo iptables -L
```


Resources:
 * [Rclone Remote setup](https://rclone.org/remote_setup/)
 * [Rclone Drive](https://rclone.org/drive/)
 * [Rclone own client_id](https://rclone.org/drive/#making-your-own-client-id)
 * [SSH tunnel rcclone solution](https://nooblinux.com/how-to-connect-rclone-to-google-drive-from-a-remote-server-headless/)




