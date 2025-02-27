{*
* 2007-2025 PrestaShop
*
* NOTICE OF LICENSE
*
* This source file is subject to the Academic Free License (AFL 3.0)
* that is bundled with this package in the file LICENSE.txt.
* It is also available through the world-wide-web at this URL:
* http://opensource.org/licenses/afl-3.0.php
*
* @author    Your Name <your.email@domain.com>
* @copyright 2007-2025 Your Company
* @license   http://opensource.org/licenses/afl-3.0.php  Academic Free License (AFL 3.0)
*}

<div class="panel">
    <div class="panel-heading">
        <i class="icon icon-cogs"></i> {l s='MTF Modules Dashboard' mod='mtf_tabs'}
    </div>

    <div class="panel-body">
        <div class="alert alert-info">
            <p><i class="icon icon-info-circle"></i>
                {l s='Welcome to the MTF modules dashboard. This is the central hub for managing all your MTF modules.' mod='mtf_tabs'}
            </p>
        </div>

        <div class="row">
            <div class="col-md-12">
                <h4>{l s='Installed MTF Modules' mod='mtf_tabs'}</h4>
            </div>
        </div>

        {if empty($mtf_modules)}
            <div class="alert alert-warning">
                {l s='No MTF module tabs have been registered yet.' mod='mtf_tabs'}
            </div>
        {else}
            <div class="row">
                {foreach from=$mtf_modules item=module}
                    <div class="col-md-4">
                        <div class="panel module-item {if !$module.active}module-disabled{/if}">
                            <div class="panel-heading">
                                <span class="module-name">{$module.displayName}</span>
                                <span class="badge">{$module.version}</span>
                                {if $module.active}
                                    <span class="badge badge-success">{l s='Active' mod='mtf_tabs'}</span>
                                {else}
                                    <span class="badge badge-danger">{l s='Inactive' mod='mtf_tabs'}</span>
                                {/if}
                            </div>
                            <div class="panel-body">
                                <p><strong>{l s='Tab:' mod='mtf_tabs'}</strong> {$module.tab_name}</p>
                                <div class="module-actions">
                                    <a href="{$module.tab_link}" class="btn btn-default">
                                        <i class="icon icon-cog"></i> {l s='Go to Module Tab' mod='mtf_tabs'}
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                {/foreach}
            </div>
        {/if}

        <div class="row">
            <div class="col-md-12">
                <div class="panel">
                    <div class="panel-heading">
                        {l s='How to Add Your Module' mod='mtf_tabs'}
                    </div>
                    <div class="panel-body">
                        <p>{l s='To add your module under this menu:' mod='mtf_tabs'}</p>
                        <ol>
                            <li>{l s='In your module\'s install() method, call the installTab() method.' mod='mtf_tabs'}
                            </li>
                            <li>{l s='Make sure to set the parent ID to the MTF Modules tab ID.' mod='mtf_tabs'}</li>
                            <li>{l s='You can use Mtf_Tabs::getParentTabId() to get the parent tab ID.' mod='mtf_tabs'}
                            </li>
                        </ol>

                        <pre class="code-example">
public function installTab()
{
    // First check if MTF Modules tab exists
    $tabRepository = $this->get('prestashop.core.admin.tab.repository');
    $tabId = null;

    try {
        $tabParent = $tabRepository->findOneByClassName('AdminMTFModules');
        if ($tabParent) {
            $tabId = $tabParent->getId();
        }
    } catch (Exception $e) {
        // Parent tab not found
    }

    // If parent tab not found, place under Improve
    if (!$tabId) {
        try {
            $tabParent = $tabRepository->findOneByClassName('IMPROVE');
            if ($tabParent) {
                $tabId = $tabParent->getId();
            }
        } catch (Exception $e) {
            // Fallback to root
            $tabId = 0;
        }
    }

    $tab = new Tab();
    $tab->active = 1;
    $tab->class_name = 'AdminYourModuleName';
    $tab->name = [];

    foreach (Language::getLanguages(true) as $lang) {
        $tab->name[$lang['id_lang']] = 'Your Module Name';
    }

    $tab->id_parent = $tabId;
    $tab->module = $this->name;

    return $tab->add();
}

public function uninstallTab()
{
    $tabRepository = $this->get('prestashop.core.admin.tab.repository');

    try {
        $tab = $tabRepository->findOneByClassName('AdminYourModuleName');
        if ($tab) {
            $tabPS = new Tab($tab->getId());
            return $tabPS->delete();
        }
    } catch (Exception $e) {
        // Tab not found, nothing to delete
    }

    return true;
}
                        </pre>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>