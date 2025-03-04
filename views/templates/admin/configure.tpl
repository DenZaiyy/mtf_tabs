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
        <i class="icon icon-cogs"></i> {l s='MTF Configure' mod='mtf_tabs'}
    </div>

    <div class="panel-body">
        <div class="alert alert-info">
            <p><i class="icon icon-info-circle"></i>
                {l s='This page shows an overview of all MTF module configuration options. Click on any module to access its specific settings.' mod='mtf_tabs'}
            </p>
        </div>

        <div class="row">
            <div class="col-md-12">
                <h4>{l s='Available MTF Modules' mod='mtf_tabs'}</h4>
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
                                        <i class="icon icon-cog"></i> {l s='Configure' mod='mtf_tabs'}
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                {/foreach}
            </div>
        {/if}
    </div>
</div>