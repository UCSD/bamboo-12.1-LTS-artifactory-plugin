/*
 * Copyright (C) 2010 JFrog Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.jfrog.bamboo.admin;

import com.atlassian.bamboo.security.GlobalApplicationSecureObject;
import com.atlassian.bamboo.ww2.actions.admin.user.AbstractEntityPagerSupport;
import com.atlassian.bamboo.ww2.aware.permissions.GlobalAdminSecurityAware;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Existing global Artifactory server configuration list action
 *
 * @author Noam Y. Tenne
 */
public class ExistingArtifactoryServerAction extends AbstractEntityPagerSupport implements GlobalAdminSecurityAware {

	private ServerConfigManager serverConfigManager;

	public ExistingArtifactoryServerAction(ServerConfigManager serverConfigManager) {
		this.serverConfigManager = serverConfigManager;
	}

	public String doBrowse() throws Exception {
		return super.execute();
	}

	public String browse() throws Exception {
		return super.execute();
	}

	public List<ServerConfig> getServerConfigs() {
		return serverConfigManager.getAllServerConfigs();
	}

	/**
	 * Returns server configs as plain Maps so FreeMarker can access values via map-key lookup.
	 * Bamboo 12.1's FreeMarker security (GenericObjectModel) blocks method invocations on
	 * non-Bamboo classes like ServerConfig, but allows java.util.Map key access.
	 */
	public List<Map<String, Object>> getServerConfigMaps() {
		List<ServerConfig> configs = serverConfigManager.getAllServerConfigs();
		List<Map<String, Object>> result = new ArrayList<>(configs.size());
		for (ServerConfig sc : configs) {
			Map<String, Object> m = new LinkedHashMap<>();
			m.put("id", sc.getId());
			m.put("url", sc.getUrl() != null ? sc.getUrl() : "");
			m.put("username", sc.getUsername() != null ? sc.getUsername() : "");
			m.put("timeout", sc.getTimeout());
			result.add(m);
		}
		return result;
	}

	@Override
	public Object getSecuredDomainObject() {
		return GlobalApplicationSecureObject.INSTANCE;
	}
}