/**
FlxKongregate
-- Part of the Flixel Power Tools set
v1.0 First release
@Version 1.0 - August 1st 2011
@link http://www.photonstorm.com
@author Richard Davey / Photon Storm 
*/

package org.flixel.plugin.photonstorm.api;

import flash.display.DisplayObject;
import flash.display.Loader;
import flash.errors.IOError;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;
import flash.system.Security;
import org.flixel.FlxG;

/**
 *  Allows for easy access to the Kongregate API
 * 
 *  Todo: Add in the functions for Chat Integration - you can still use them via the FlxKongregate.api object.
 */
class FlxKongregate 
{
    /**
     * The Kongregate API object. You can make calls directly to this once the API has connected.
     */
    public static var api:Dynamic;

    /**
     * true if the API has loaded otherwise false. Loaded is not the same thing as connected, it just means it's ready for the connection.
     */
    public static var hasLoaded:Bool = false;

    /**
     * Is the game running locally in Shadow API mode (true) or from Kongregates servers (false)
     */
    public static var isLocal:Bool = false;

    private static var shadowAPI:String = "http://www.kongregate.com/flash/API_AS3_Local.swf";
    private static var apiLoader:Loader;
    private static var loadCallback:Dynamic;

    public function new() {  }

    /**
     * Loads the Kongregate API and if successful connects to the service.
     * Note that your game must have access to Stage by this point.
     * 
     * @param   callback    This function is called if the API loads successfully. Do not call any API function until this has happened.
     */
    public static function init(cb:Dynamic):Void
    {
        var parameters:Dynamic;
        try
        {
            parameters = FlxG.stage.loaderInfo.parameters;
        }
        catch (e:String)
        {
            throw "FlxKongregate: No access to FlxG.stage - only call this once your game has access to the display list";
            return;
        }

        var apiPath:String;

        if (parameters.kongregate_api_path)
        {
            Security.allowDomain(parameters.kongregate_api_path);
            apiPath = parameters.kongregate_api_path;
        }
        else
        {
            Security.allowDomain(shadowAPI);
            apiPath = shadowAPI;
            isLocal = true;
        }

        loadCallback = cb;

        apiLoader = new Loader();
        apiLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, apiLoadComplete, false, 0, true);
        apiLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, apiLoadError, false, 0, true);
        apiLoader.load(new URLRequest(apiPath));

        FlxG.stage.addChild(apiLoader);
    }

    /**
     * Remove the API from memory (when possible) and removes it from the display list also
     */
    public static function disconnect():Void
    {
        api = null;

        hasLoaded = false;

        FlxG.stage.removeChild(apiLoader);
    }

    private static function apiLoadComplete(event:Event):Void
    {
        api = event.target.content;

        hasLoaded = true;

        Security.allowDomain(api.loaderInfo.url);

        if (Std.is (loadCallback, Dynamic))
        {
            loadCallback.call();
        }
    }

    private static function apiLoadError(error:IOError):Void
    {
        FlxG.log("Error loading Kongregate API:" + error);
    }

    /**
     * Use the addLoadListener function to register an event listener which will be triggered when content of the specified type is loaded by the user.
     * These MUST be set-up *before* you call FlxKongregate.connect()
     * See: http://www.kongregate.com/developer_center/docs/shared-content-api
     * 
     * @param   contentType     Type of content to listen for
     * @param   callback        Function to call when content load request has been made
     */
    public static function addLoadListener(contentType:String, cb:Void):Void
    {
        api.sharedContent.addLoadListener(contentType, cb);
    }

    /**
     * Register an event listener with the API. Useful for capturing guest to user login requests for example.
     * See: http://www.kongregate.com/developer_center/docs/handling-guests
     * 
     * @param   contentType     The event to listen for (i.e. "login")
     * @param   callback        Funcation to call when this event is received
     */
    public static function addEventListener(contentType:String, cb:Void):Void
    {
        api.services.addEventListener(contentType, cb);
    }

    /**
     * Connect to the Kongregate API. This should be called only after the init callback reports a succesful load of the API
     */
    public static function connect():Void
    {
        if (hasLoaded)
        {
            api.services.connect();
        }
    }

    /**
     * The isGuest function can be called to determine if the player is currently signed into Kongregate or not
     */
    public static function  isGuest():Bool
    {
        return api.services.isGuest();
    }

    /**
     * You can use the getUsername() function to retrieve the username of the current player. It will begin with Guest if the user is not signed in.
     */
    public static function  getUserName():String
    {
        return api.services.getUsername();
    }

    /**
     * You can use the getUserId() function to retrieve the unique user id of the current player. It will return 0 if the user is not signed in.
     */
    public static function  getUserId():Float
    {
        try
        {
            return api.services.getUserId();
        }
        catch (e:String)
        {
            return 0;
        }

        return 0;
    }

    /**
     * If you are using the Authentication API you can use the getGameAuthToken function to get the player's game authentication token.
     */
    public static function  getGameAuthToken():String
    {
        return api.services.getGameAuthToken();
    }

    /**
     * If the player is a guest, and you want to display the sign-in/registration UI to them you can use the showSignInBox function.
     */
    public static function showSignInBox():Void
    {
        if (api.services.isGuest())
        {
            api.services.showSignInBox();
        }
    }

    /**
     * This call works the same way as showSigninBox, but it focuses the registration form rather than the sign-in form.
     */
    public static function showRegistrationBox():Void
    {
        if (api.services.isGuest())
        {
            api.services.showRegistrationBox();
        }
    }

    /**
     * If a player is logged-in and you want to allow them to post a shout on their profile page, you may bring up the shout box, optionally populated with some initial content.
     * 
     * @param   message     The optional initial content
     */
    public static function showShoutBox(?message:String = ""):Void
    {
        if (api.services.isGuest() == false)
        {
            api.services.showShoutBox(message);
        }
    }

    /**
     * If you need to resize your game's enclosing container, you may do so with resizeGame call. The enclosing iframe will resize around your game.
     * Games may not be resized smaller than their initial dimensions. This call requires special permission from Kongregate to use.
     * 
     * @param   width       New width (in pixels) of the container
     * @param   height      New height (in pixels) of the container
     */
    public static function resizeGame(width:Int, height:Int):Void
    {
        api.services.resizeGame(width, height);
    }

    /**
     * Submit a statistic to the Kongregate server. Make sure you have defined the stat before calling this.
     * See the Kongregate API documentation for details.
     * 
     * @param   name        The name of the statistic
     * @param   value       The value to submit (will be converted to an integer server-side)
     */
    public static function submitStats(name:String, value:Float):Void
    {
        api.stats.submit(name, value);
    }

    public static function submitScore(score:Float, mode:String):Void
    {
        // api.stats.submit(name, value);
        api.scores.submit(score, mode);
    }

    /**
     * Bring up the "purchase items" dialog box by using the purchaseItems method on the microtransaction services object.
     * Your game must be in the Kongregate Microtransactions beta to use this function.
     * See: http://www.kongregate.com/developer_center/docs/microtransaction-client-api
     * 
     * @param   items       The array of item identifier strings or item/metadata objects.
     * @param   callback    The callback function
     */
    public static function purchaseItem(items:Array<Dynamic>, cb:Void):Void
    {
        api.mtx.purchaseItems(items, cb);
    }

    /**
     * Request the inventory of any user.
     * Your game must be in the Kongregate Microtransactions beta to use this function.
     * See: http://www.kongregate.com/developer_center/docs/microtransaction-client-api
     * 
     * @param   username    The username to request inventory for, or null for the current player
     * @param   callback    The callback function
     */
    public static function requestUserItemList(username:String, cb:Void):Void
    {
        api.mtx.requestUserItemList(username, cb);
    }

    /**
     * Display the Kred purchasing Dialog.
     * Your game must be in the Kongregate Microtransactions beta to use this function.
     * See: http://www.kongregate.com/developer_center/docs/microtransaction-client-api
     * 
     * @param   purchaseMethod   The purchase method to display. Should be "offers" or "mobile"
     */
    public static function showKredPurchaseDialog(purchaseMethod:String):Void
    {
        api.mtx.showKredPurchaseDialog(purchaseMethod);
    }

    /**
     * The browse function causes a list of shared content to appear in the user's browser.
     * This will allow them to view, rate, or load shared content for your game.
     * See: http://www.kongregate.com/developer_center/docs/shared-content-api
     * 
     * @param   contentType     Type of content to browse
     * @param   sortOrder       Optional constant specifying how to sort content (see API docs)
     * @param   label           Optional, only browse content saved with the specified label
     */
    public static function browseSharedContent(contentType:String, ?sortOrder:String = null, ?label:String = null):Void
    {
        api.sharedContent.browse(contentType, sortOrder, label);
    }

    /**
     * Use the save function to submit shared content on the Kongregate back-end.
     * See: http://www.kongregate.com/developer_center/docs/shared-content-api
     * 
     * @param   type        Type of content the user wishes to save, 12 characters max.
     * @param   content     Value of content to be saved. We strongly recommend keeping these values under 100K.
     * @param   callback    Function to call when save has finished.
     * @param   thumb       Optional but highly recommended! Send us a DisplayObject that we will snapshotted and used as a thumbnail for the content.
     * @param   label       Optional, label for sub-classing the shared content.
     */
    public static function saveSharedContent(type:String, content:String, cb:Void, ?thumb:DisplayObject = null, ?label:String = null):Void
    {
        api.sharedContent.save(type, content, cb, thumb, label);
    }

    /**
     * Export a DisplayObject to be converted to a user avatar. It is highly recommended that avatars be at least 40 x 40px.
     * See: http://www.kongregate.com/developer_center/docs/avatar-api
     * 
     * @param   avatar      Can be null, but highly recommended that you send yourself. If null, we will snapshot the stage.
     * @param   callback    Function to call when content load request has been made
     */
    public static function submitAvatar(avatar:DisplayObject, cb:Void):Void
    {
        api.images.submitAvatar(avatar, cb);
    }
}