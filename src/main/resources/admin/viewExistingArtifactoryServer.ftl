[#-- @ftlvariable name="action" type="org.jfrog.bamboo.admin.ExistingArtifactoryServerAction" --]
[#-- @ftlvariable name="" type="org.jfrog.bamboo.admin.ExistingArtifactoryServerAction" --]

<div class="toolbar">
    <div class="aui-toolbar inline">
        <ul class="toolbar-group">
            <li class="toolbar-item">
                <a class="toolbar-trigger"
                   href="[@s.url action='artifactoryServerConfig' namespace='/admin' /]">
                [@s.text name='artifactory.server.add' /]</a>
            </li>
        </ul>
    </div>
</div>

<br/>

[@ui.bambooPanel]

<div>
<table id="existingArtifactoryServer" class="aui">
    <thead>
    <tr>
        <th>Artifactory Server URL</th>
        <th>Username</th>
        <th>Timeout</th>
        <th class="operations">Operations</th>
    </tr>
    </thead>
    [#-- Use serverConfigMaps (List<Map>) instead of serverConfigs (List<ServerConfig>).
         Bamboo 12.1 FreeMarker security blocks method invocations on non-Bamboo POJOs;
         Map key access is unrestricted. --]
    [#if (serverConfigMaps?? && serverConfigMaps?has_content)]
        [#foreach serverConfig in serverConfigMaps]
            <tr>
                <td>
                    <a href="${serverConfig.url}" target="_blank" >${serverConfig.url}</a>
                </td>
                <td>
                ${serverConfig.username}
                </td>
                <td>
                ${serverConfig.timeout}
                </td>
                <td class="operations">
                    <a id="editServer-${serverConfig.id}" href="[@ww.url action='editServer' serverId=serverConfig.id/]">
                        Edit
                    </a>
                    |
                    <a id="deleteServer-${serverConfig.id}"
                       href="[@ww.url action='confirmDeleteServer' serverId=serverConfig.id returnUrl=currentUrl/]"
                       title="[@ww.text name='artifactory.server.delete' /]">[@ww.text name="global.buttons.delete" /]
                    </a>
                </td>
            </tr>
        [/#foreach]
    [#else]
        <tr>
            <td class="labelPrefixCell" colspan="4">
                [@ww.text name="artifactory.server.manage.none"/]
            </td>
        </tr>
    [/#if]
</table>
</div>
[/@ui.bambooPanel]

[#-- simpleDialogForm removed: the dialog-based delete does not work in Bamboo 12.1.
     Delete links navigate directly to confirmDeleteServer.ftl which has the confirmation form. --]

[#--[@cp.entityPagination actionUrl='${req.contextPath}/admin/jfrogConfig.action?' paginationSupport=paginationSupport /]--]
