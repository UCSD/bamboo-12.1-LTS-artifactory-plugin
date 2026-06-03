[#assign taskPlanKey = ''/]
[#if plan?? && plan.key??]
    [#assign taskPlanKey = plan.key?string/]
[#elseif relatedPlan?? && relatedPlan.key??]
    [#assign taskPlanKey = relatedPlan.key?string/]
[/#if]
<input type="hidden" name="jfrogCmlTaskUiFixVersion" value="2026.1.2"/>
<script>
    (function () {
        var renderedPlanKey = '${taskPlanKey?js_string}';
        var keyNames = ['buildKey', 'planKey', 'chainKey', 'jobKey'];

        function getUrlSearch(value) {
            try {
                return value ? new URL(value, window.location.href).search : '';
            } catch (e) {
                return '';
            }
        }

        function copySearchParams(target, search) {
            if (!search) {
                return;
            }

            var params = new URLSearchParams(search);
            keyNames.forEach(function (name) {
                var value = params.get(name);
                if (value && !target[name]) {
                    target[name] = value;
                }
            });
        }

        function readExistingFormValue(form, name) {
            if (!form) {
                return '';
            }

            var input = form.querySelector('[name="' + name + '"]');
            return input && input.value ? input.value : '';
        }

        function getCandidateKeys(form) {
            var values = {};
            keyNames.forEach(function (name) {
                var value = readExistingFormValue(form, name);
                if (value) {
                    values[name] = value;
                }
            });

            copySearchParams(values, getUrlSearch(form ? form.getAttribute('action') : ''));
            copySearchParams(values, window.location.search);
            copySearchParams(values, getUrlSearch(document.referrer));

            if (renderedPlanKey) {
                values.buildKey = values.buildKey || renderedPlanKey;
                values.planKey = values.planKey || renderedPlanKey;
                values.jobKey = values.jobKey || renderedPlanKey;
            }

            return values;
        }

        function firstPresent() {
            for (var i = 0; i < arguments.length; i++) {
                if (arguments[i]) {
                    return arguments[i];
                }
            }
            return '';
        }

        function stripActionKeyParams(form) {
            var action = form.getAttribute('action') || form.action;
            if (!action) {
                return;
            }

            try {
                var actionUrl = new URL(action, window.location.href);
                var changed = false;
                keyNames.forEach(function (name) {
                    if (actionUrl.searchParams.has(name)) {
                        actionUrl.searchParams.delete(name);
                        changed = true;
                    }
                });
                if (changed) {
                    form.action = actionUrl.href;
                }
            } catch (e) {
            }
        }

        function setSingleHidden(form, name, value) {
            if (!value) {
                return;
            }
            var inputs = Array.prototype.slice.call(form.querySelectorAll('input[name="' + name + '"]'));
            var input = inputs.filter(function (candidate) {
                return candidate.value;
            })[0] || inputs[0];
            if (!input) {
                input = document.createElement('input');
                input.type = 'hidden';
                input.name = name;
                form.appendChild(input);
            }
            if (!input.value) {
                input.value = value;
            }
            inputs.forEach(function (candidate) {
                if (candidate !== input && candidate.type === 'hidden' && candidate.parentNode) {
                    candidate.parentNode.removeChild(candidate);
                }
            });
        }

        function ensureFormPlanKey(form) {
            if (!form || !/createTask\.action|updateTask\.action/.test(form.action || '')) {
                return;
            }

            var candidates = getCandidateKeys(form);
            stripActionKeyParams(form);
            var contextKey = firstPresent(candidates.jobKey, candidates.buildKey, candidates.planKey, renderedPlanKey);
            if (!contextKey) {
                return;
            }

            var buildKey = firstPresent(candidates.buildKey, contextKey);
            var planKey = firstPresent(candidates.planKey, contextKey);
            var values = {
                buildKey: buildKey,
                planKey: planKey,
                chainKey: candidates.chainKey,
                jobKey: firstPresent(candidates.jobKey, contextKey)
            };

            setSingleHidden(form, 'buildKey', buildKey);
            setSingleHidden(form, 'planKey', planKey);
            setSingleHidden(form, 'jfrogCmlTaskUiFixVersion', '2026.1.2');

            ['chainKey', 'jobKey'].forEach(function (name) {
                setSingleHidden(form, name, values[name]);
            });
        }

        function ensureTaskPlanKey() {
            document.querySelectorAll('form[action*="createTask.action"], form[action*="updateTask.action"]').forEach(ensureFormPlanKey);
        }

        [0, 50, 250, 1000].forEach(function (delay) {
            window.setTimeout(ensureTaskPlanKey, delay);
        });
        if (window.MutationObserver) {
            new MutationObserver(ensureTaskPlanKey).observe(document.documentElement, {
                childList: true,
                subtree: true
            });
        }
        document.addEventListener('submit', function (event) {
            ensureFormPlanKey(event.target);
        }, true);
        document.addEventListener('click', function (event) {
            var target = event.target;
            var submitter = target && target.closest ? target.closest('button, input[type="submit"], a') : null;
            if (!submitter) {
                return;
            }
            var form = submitter.form || (submitter.closest ? submitter.closest('form') : null);
            ensureFormPlanKey(form);
        }, true);

        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', ensureTaskPlanKey);
        } else {
            ensureTaskPlanKey();
        }
    })();
</script>
