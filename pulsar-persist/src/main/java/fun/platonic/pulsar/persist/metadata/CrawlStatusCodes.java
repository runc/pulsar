/*******************************************************************************
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 ******************************************************************************/
package fun.platonic.pulsar.persist.metadata;

public interface CrawlStatusCodes {
    /**
     * Page was not fetched yet.
     */
    byte UNFETCHED = 0x01;
    /**
     * Page was successfully fetched.
     */
    byte FETCHED = 0x02;
    /**
     * Page no longer exists.
     */
    byte GONE = 0x03;
    /**
     * Page temporarily redirects to other page.
     */
    byte REDIR_TEMP = 0x04;
    /**
     * Page permanently redirects to other page.
     */
    byte REDIR_PERM = 0x05;
    /**
     * Fetching unsuccessful, needs to be retried (transient errors).
     */
    byte RETRY = 0x22;
    /**
     * Fetching successful - page is not modified.
     */
    byte NOTMODIFIED = 0x26;
}
