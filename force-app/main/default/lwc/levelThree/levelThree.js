import { LightningElement, api } from 'lwc';

export default class LevelThree extends LightningElement {
    @api recordId
    @api whatColor
    @api whichObject


    get colorspec(){
        return this.whatColor.toLowerCase();
    }

    get isRecordPage(){
        return typeof this.recordId !== "undefined";
    }

    get talkbubble(){
        switch(this.whatColor){
            case "Blue":
                return "talk-bubble-in round left-top shadow tri-right-Blue protonLightBlue";
            case "Yellow":
                return "talk-bubble-in round left-top shadow tri-right-Yellow protonLightYellow";
            case "Green":
                return "talk-bubble-in round left-top shadow tri-right-Green protonLightGreen";
            case "Purple":
                return "talk-bubble-in round left-top shadow tri-right-Indigo protonLightIndigo";
            default:
                return "talk-bubble-in round left-top shadow tri-right-White protonWhite";
        }
    }
    
}