package me.botsko.prism.measurement;

import java.util.Calendar;
import java.util.Collections;
import java.util.Map;
import java.util.TreeMap;

public class TimeTaken {

	/**
	 * 
	 */
	protected Map<Long,String> eventsTimed = Collections.synchronizedMap(new TreeMap<Long,String>());
	
	
	/**
	 * 
	 * @return
	 */
	protected long getTimestamp(){
		Calendar lCDateTime = Calendar.getInstance();
		return lCDateTime.getTimeInMillis();
	}
	
	
	/**
	 * 
	 * @param eventname
	 */
	public void recordTimedEvent( String eventname ){
		eventsTimed.put(getTimestamp(), eventname);
	}
	
	
	/**
	 * 
	 */
	public void resetEventList(){
		eventsTimed.clear();
	}
	
	
	/**
	 * 
	 * @return
	 */
	public Map<Long,String> getEventsTimedList(){
		return eventsTimed;
	}
}
