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
    // First check if mtf_tabs module exists and is installed
    if (!Module::isInstalled('mtf_tabs')) {
        // Fallback to IMPROVE tab
        $tabRepository = $this->get('prestashop.core.admin.tab.repository');
        $improveTab = $tabRepository->findOneByClassName('IMPROVE');
        $parentId = $improveTab ? $improveTab->getId() : 0;
    } else {
        // Instancier le module mtf_tabs pour accéder à ses méthodes
        $mtfTabsModule = Module::getInstanceByName('mtf_tabs');

        // Vérifier si la classe est disponible avant d'essayer d'utiliser ses méthodes
        if (method_exists('Mtf_Tabs', 'getConfigureTabId')) {
            $configureId = Mtf_Tabs::getConfigureTabId();

            if (!$configureId && method_exists('Mtf_Tabs', 'getParentTabId')) {
                $configureId = Mtf_Tabs::getParentTabId();
            }

            $parentId = $configureId ?: 0;
        } else {
            // Fallback: récupérer directement l'ID depuis la base de données
            $sql = 'SELECT id_tab FROM ' . _DB_PREFIX_ . 'tab WHERE class_name = "AdminMTFConfigure"';
            $configureId = Db::getInstance()->getValue($sql);

            if (!$configureId) {
                $sql = 'SELECT id_tab FROM ' . _DB_PREFIX_ . 'tab WHERE class_name = "AdminMTFModules"';
                $configureId = Db::getInstance()->getValue($sql);
            }

            $parentId = $configureId ?: 0;
        }
    }

    $tab = new Tab();
    $tab->active = 1;
    $tab->class_name = 'AdminYourModuleName';
    $tab->name = [];

    foreach (Language::getLanguages(true) as $lang) {
        $tab->name[$lang['id_lang']] = 'Your Module Name';
    }

    $tab->id_parent = $parentId;
    $tab->module = $this->name;

    return $tab->add();
}

/**
* Uninstall Tab
*/
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