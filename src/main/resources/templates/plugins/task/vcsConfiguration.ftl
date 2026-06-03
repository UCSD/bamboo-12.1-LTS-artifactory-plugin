[@s.select
labelKey=i18n.getText('artifactory.vcs.type')
name='artifactory.vcs.type'
toggle=true
list="artifactory.vcs.git.vcs.type.list"
listKey='name'
listValue='label']
[/@s.select]

[@ui.bambooSection dependsOn='artifactory.vcs.type' showOn='GIT']

    [@ww.textfield labelKey=i18n.getText('artifactory.vcs.git.url') name='artifactory.vcs.git.url' required=true/]

    [@s.select
    labelKey=i18n.getText('artifactory.vcs.git.authenticationType')
    name='artifactory.vcs.git.authenticationType'
    toggle=true
    list="artifactory.vcs.git.authenticationType.list"
    listKey='name'
    listValue='label']
    [/@s.select]

    [@ui.bambooSection dependsOn='artifactory.vcs.git.authenticationType' showOn='PASSWORD']
        [@ww.textfield labelKey=i18n.getText('artifactory.vcs.git.username') name='artifactory.vcs.git.username' required=true/]
        [@ww.password labelKey=i18n.getText('artifactory.vcs.git.password') name='artifactory.vcs.git.password' showPassword='true' required=true/]
            [#--The Dummy password is a workaround for the autofill (Chrome)--]
        <div style="visibility:hidden; position:absolute; height:0; overflow:hidden;">
        [@ww.password name='artifactory.password.DUMMY'/]
        </div>
    [/@ui.bambooSection]
    [@ui.bambooSection dependsOn='artifactory.vcs.git.authenticationType' showOn='SSH_KEYPAIR']
        [#-- Changed from [@s.file] to [@ww.textarea]: a file input forces multipart/form-data
             which breaks planKey binding in Struts2 7.x (Bamboo 12.1), causing 500 on task
             configuration save. SSH keys are PEM text — textarea is functionally equivalent. --]
        [@ww.textarea labelKey=i18n.getText('artifactory.vcs.git.ssh.key') name='artifactory.vcs.git.ssh.key' rows='6' cols='60'/]
        [@s.password labelKey=i18n.getText('artifactory.vcs.git.ssh.passphrase') name='artifactory.vcs.git.ssh.passphrase' showPassword='true'/]
            [#--The Dummy password is a workaround for the autofill (Chrome)--]
        <div style="visibility:hidden; position:absolute; height:0; overflow:hidden;">
        [@ww.password name='artifactory.password.DUMMY'/]
        </div>
    [/@ui.bambooSection]
[/@ui.bambooSection]
[@ui.bambooSection dependsOn='artifactory.vcs.type' showOn='PERFORCE']
    [@s.textfield labelKey=i18n.getText('artifactory.vcs.p4.port') name='artifactory.vcs.p4.port' required=true /]
    [@s.textfield labelKey=i18n.getText('artifactory.vcs.p4.client') name='artifactory.vcs.p4.client' required=true cssClass="long-field" /]
    [@s.textfield labelKey=i18n.getText('artifactory.vcs.p4.depot') name='artifactory.vcs.p4.depot' required=true cssClass="long-field" /]
    [@s.textfield labelKey=i18n.getText('artifactory.vcs.p4.username') name='artifactory.vcs.p4.username' /]
    [@s.password labelKey=i18n.getText('artifactory.vcs.p4.password') name='artifactory.vcs.p4.password' showPassword='true' required=false/]
        [#--The Dummy password is a workaround for the autofill (Chrome)--]
    <div style="visibility:hidden; position:absolute; height:0; overflow:hidden;">
        [@ww.password name='artifactory.password.DUMMY'/]
        </div>
[/@ui.bambooSection]