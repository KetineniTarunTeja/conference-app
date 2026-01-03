import { LightningElement, api, track } from 'lwc';
import getFutureSessions from '@salesforce/apex/SpeakerController.getFutureSessions';
import checkAvailability from '@salesforce/apex/SpeakerController.checkAvailability';
import createAssignment from '@salesforce/apex/SpeakerController.createAssignment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class BookSession extends LightningElement {

    _speaker;

    @track sessionOptions = [];
    selectedSession;
    isDisabled = true;

    @api
    set speaker(value) {
        this._speaker = value;
        this.resetState();

        if (value) {
            this.loadSessions();
        }
    }

    get speaker() {
        return this._speaker;
    }

    loadSessions() {
        getFutureSessions()
            .then(result => {
                this.sessionOptions = result.map(s => ({
                    label: `${s.Title__c} (${s.Session_Date__c})`,
                    value: s.Id
                }));
            })
            .catch(error => {
                console.error(error);
            });
    }

    resetState() {
        this.sessionOptions = [];
        this.selectedSession = null;
        this.isDisabled = true;
    }

    handleSessionChange(event) {

        if (!this.speaker) {
            return;
        }

        this.selectedSession = event.target.value;
        this.isDisabled = true;

        checkAvailability({
            speakerId: this.speaker.Id,
            sessionId: this.selectedSession
        })
        .then(isAvailable => {
            if (isAvailable) {
                this.isDisabled = false;
            } else {
                this.showToast(
                    'Error',
                    'Slot is already booked, try another date',
                    'error'
                );
            }
        })
        .catch(error => {
            console.error(error);
        });
    }

    handleCreate() {
        createAssignment({
            speakerId: this.speaker.Id,
            sessionId: this.selectedSession
        })
        .then(() => {
            this.showToast(
                'Success',
                'Speaker assigned successfully',
                'success'
            );
            this.isDisabled = true;
        })
        .catch(error => {
            console.error(error);
        });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}