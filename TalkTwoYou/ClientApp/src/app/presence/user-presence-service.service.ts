import { Injectable } from '@angular/core';
import { AngularFireAuth } from '@angular/fire/compat/auth';
import { getDatabase, ref, update } from '@angular/fire/database';

@Injectable({
  providedIn: 'root'
})
export class UserPresenceServiceService {

  constructor(private auth: AngularFireAuth) {
    this.manageOnlineStatus();
   }


  manageOnlineStatus() {
    document.addEventListener(
      "visibilitychange"
      ,() => {
        if (document.hidden) {
          this.auth.user.subscribe((authUser) => {
            const user = authUser?.uid;
            const db = getDatabase();
            let userRef = ref(db, user);
            let updateStatus = {'status': 'offline'};
            update(userRef, updateStatus);

          })
        }else{
          this.auth.user.subscribe((authUser) => {
            const user = authUser?.uid;
            const db = getDatabase();
            let userRef = ref(db, user);
            let updateStatus = {'status': 'online'};
            update(userRef, updateStatus);

          })
        }
      }
    );  }
}
