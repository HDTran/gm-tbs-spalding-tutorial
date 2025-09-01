event_inherited(); // does nothing, but will inherit anything from oBattleUnit for later
if (hp <= 0) {
    // better to disable them than destroy, keeping all data in play incase of ressurection and the like
    image_blend = c_red;
    image_alpha -= 0.01;
}